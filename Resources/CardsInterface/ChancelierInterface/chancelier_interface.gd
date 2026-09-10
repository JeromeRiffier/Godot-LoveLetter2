class_name ChancelierInterface extends CardInterface

@onready var message: Message = $Message

var cards:Array[Card]

var dragging_card:Card
var dragging_card_starting_pos:Vector2


func enter() -> void:
	super() # Execute parenter enter func
	#validate()
	dragging_card = null
	player_ref.need_card.emit(player_ref)
	player_ref.need_card.emit(player_ref)
	cards.assign(player_ref.hand.cards)
	await get_tree().create_timer(1.5).timeout
	for card in cards:
		print("remove %s from hand" % card.infos.title)
		await player_ref.hand.remove_card_from_hand(card)
	await animate_cards_to_center()
	message.display_text("Fait ton choix")

func _unhandled_input(event: InputEvent) -> void:
	if not is_active:
		return
	get_viewport().set_input_as_handled()
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			var space_state := get_world_2d().direct_space_state
			var parameters := PhysicsPointQueryParameters2D.new()
			parameters.position = get_global_mouse_position()
			parameters.collide_with_areas = true
			parameters.collision_mask = Constant.CARD_MASK
			var colision_result := space_state.intersect_point(parameters)
			var colision_filtered = colision_result.filter(func (result:Dictionary) -> bool: return cards.has(result.collider.get_parent()) )
			if not colision_filtered.is_empty():
				var card:Card = colision_filtered[0].collider.get_parent()
				dragging_card = card
				dragging_card_starting_pos = dragging_card.global_position
		else: 
			if not dragging_card:
				return
			var deck = detect_deck_collision()
			var player = detect_player_collision()
			if player:
				if player.hand.cards.is_empty():
					cards.erase(dragging_card)
					player.draw_card(dragging_card)
					dragging_card = null
				else: 
					message.display_text("Il y a deja une carte dans ton deck")
					dragging_card.global_position = dragging_card_starting_pos
					dragging_card = null
			elif deck:
				if last_card_for_player():
					message.display_text("La derniere carte et pour toi")
					dragging_card.global_position = dragging_card_starting_pos
					dragging_card = null
				else:
					player_ref.return_card.emit(dragging_card)
					cards.erase(dragging_card)
					dragging_card = null
			else:
				dragging_card.global_position = dragging_card_starting_pos
				dragging_card = null
			if cards.is_empty():
				validate()

## return tru if there is only one card left to choose and the player haven't got his
func last_card_for_player() -> bool:
	return cards.size() == 1 && player_ref.hand.cards.is_empty()

func detect_deck_collision() -> Deck:
	var space_state := get_world_2d().direct_space_state
	var parameters := PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = Constant.DECK_MASK
	var colision_result := space_state.intersect_point(parameters)
	if colision_result.is_empty():
		return null
	return colision_result[0].collider.get_parent() as Deck

func detect_player_collision() -> Player:
	var space_state := get_world_2d().direct_space_state
	var parameters := PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = Constant.PLAYER_MASK
	var colision_result := space_state.intersect_point(parameters)
	if colision_result.is_empty():
		return null
	return colision_result[0].collider.get_parent() as Player

func _process(delta: float) -> void:
	if dragging_card:
		dragging_card.global_position = get_global_mouse_position()

#region Card positioning
func animate_cards_to_center() -> void:
	var center_y := (get_tree().root.size.y /2.0) +  80.0
	for i in range(cards.size()):
		var new_position =  Vector2(calculate_card_positions_x(i), center_y)
		var card := cards[i]
		card.position_in_hand = new_position
		animate_card_to_position(card, new_position)


func calculate_card_positions_x(index:int) -> float:
	var total_width := cards.size() * Constant.CARD_WIDTH
	var x_offset := get_tree().root.size.x /2.0 + index * Constant.CARD_WIDTH - total_width / 2.0 + (Constant.CARD_WIDTH / 2.0)
	return x_offset
func animate_card_to_position(card:Card, new_position:Vector2) -> void:
	var tween = create_tween()
	tween.tween_property(card, "global_position", new_position, 0.3)
#endregion
