class_name EnemyAIChancelierInterface extends CardInterface

@onready var message: Message = $Message

var cards:Array[Card]

var dragging_card:Card
var dragging_card_starting_pos:Vector2


func enter() -> void:
	super() # Execute parenter enter func
	dragging_card = null
	player_ref.need_card.emit(player_ref)
	player_ref.need_card.emit(player_ref)
	await player_ref.hand.card_repositioned
	for i in range(3):
		cards.append(player_ref.hand.cards[0])
		player_ref.hand.remove_card_from_hand(player_ref.hand.cards[0])
		animate_cards_to_center()
	
	message.display_text("Fait ton choix")

func _unhandled_input(event: InputEvent) -> void:
	if not is_active:
		return
	get_viewport().set_input_as_handled()
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			var card = detect_card_collision()
			if card:
				start_dragging(card)
		else: 
			if not dragging_card:
				return
			var deck = detect_deck_collision()
			var player = detect_player_collision()
			if player:
				manage_player_card_drop()
			elif deck:
				manage_deck_card_drop()
			else:
				stop_dragging()
			if cards.is_empty():
				validate()


func start_dragging(card:Card) -> void:
	dragging_card = card
	dragging_card_starting_pos = dragging_card.global_position
func stop_dragging() -> void:
	dragging_card.global_position = dragging_card_starting_pos
	dragging_card = null


func manage_player_card_drop() -> void:
	if player_ref.hand.cards.is_empty():
		cards.erase(dragging_card)
		player_ref.draw_card(dragging_card)
		dragging_card = null
	else: 
		message.display_text("Il y a deja une carte dans ton deck")
		stop_dragging()

func manage_deck_card_drop() -> void:
	if last_card_for_player():
		message.display_text("La derniere carte et pour toi")
		stop_dragging()
	else:
		player_ref.return_card.emit(dragging_card)
		cards.erase(dragging_card)
		dragging_card = null

## return true if there is only one card left to choose and the player haven't got his
func last_card_for_player() -> bool:
	return cards.size() == 1 && player_ref.hand.cards.is_empty()

func detect_card_collision() -> Card:
	var space_state := get_world_2d().direct_space_state
	var parameters := PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = Constant.CARD_MASK
	var colision_result := space_state.intersect_point(parameters)
	var colision_filtered = colision_result.filter(func (result:Dictionary) -> bool: return cards.has(result.collider.get_parent()) )
	if colision_filtered.is_empty():
		return null
	var card:Card = colision_filtered[0].collider.get_parent()
	return card

func detect_deck_collision() -> bool:
	var space_state := get_world_2d().direct_space_state
	var parameters := PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = Constant.DECK_MASK
	var colision_result := space_state.intersect_point(parameters)
	if colision_result.is_empty():
		return false
	return true

func detect_player_collision() -> bool:
	var space_state := get_world_2d().direct_space_state
	var parameters := PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = Constant.PLAYER_MASK
	var colision_result := space_state.intersect_point(parameters)
	if colision_result.is_empty():
		return false
	var player:Player = colision_result[0].collider.get_parent()
	if player != player_ref:
		printerr("WTF On devrais pas avoir plus RealPlayer")
		return false
	return true

func _process(_delta: float) -> void:
	if dragging_card:
		dragging_card.global_position = get_global_mouse_position()

#region Card positioning
func animate_cards_to_center() -> void:
	var center_y := (get_tree().root.size.y /2.0) +  80.0
	for i in range(cards.size()):
		var new_position =  Vector2(calculate_card_positions_x(i), center_y)
		var card := cards[i]
		card.position_in_hand = new_position
		await animate_card_to_position(card, new_position)


func calculate_card_positions_x(index:int) -> float:
	var total_width := cards.size() * Constant.CARD_WIDTH
	var x_offset := get_tree().root.size.x /2.0 + index * Constant.CARD_WIDTH - total_width / 2.0 + (Constant.CARD_WIDTH / 2.0)
	return x_offset
func animate_card_to_position(card:Card, new_position:Vector2) -> void:
	var tween = create_tween()
	tween.tween_property(card, "global_position", new_position, 0.3)
	await tween.finished
#endregion
