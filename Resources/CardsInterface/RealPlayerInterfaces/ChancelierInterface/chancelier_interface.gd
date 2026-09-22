class_name PlayerChancelierInterface extends ChancelierInterface


var dragging_card:Card
var dragging_card_starting_pos:Vector2


func enter() -> void:
	await super() # Execute parenter enter func
	dragging_card = null
	message.display_text("Fait ton choix")
	enable_card_selection()
	


func _unhandled_input(event: InputEvent) -> void:
	if not is_active:
		return
	get_viewport().set_input_as_handled()
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			var card := detect_card_collision()
			if card:
				start_dragging(card)
		else: 
			if not dragging_card:
				return
			var deck := detect_deck_collision()
			var player := detect_player_collision()
			if player:
				manage_player_card_drop(dragging_card)
			elif deck:
				manage_deck_card_drop(dragging_card)
			else:
				stop_dragging()
			if cards.is_empty():
				validate()


func start_dragging(card:Card) -> void:
	dragging_card = card
	dragging_card_starting_pos = dragging_card.global_position
func stop_dragging() -> void:
	if not dragging_card:
		return
	dragging_card.global_position = dragging_card_starting_pos
	dragging_card = null


func manage_player_card_drop(card:Card) -> void:
	if player_ref.hand.cards.is_empty():
		cards.erase(card)
		await player_ref.draw_card(card)
		dragging_card = null
	else: 
		message.display_text("Il y a deja une carte dans ton deck")
		stop_dragging()

func manage_deck_card_drop(card:Card) -> void:
	if last_card_for_player():
		message.display_text("La derniere carte et pour toi")
		stop_dragging()
	else:
		player_ref.return_card.emit(card)
		cards.erase(card)
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
	var colision_filtered := colision_result.filter(func (result:Dictionary) -> bool: return cards.has(result.collider.get_parent()) )
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


func enable_card_selection() -> void:
	for card in cards:
		card.selectable = true
		card.selected.connect(manage_card_selected)
	_pre_point()

func disable_card_selection() -> void:
	for card in cards:
		card.selectable = false
		card.selected.disconnect(manage_card_selected)

func manage_card_selected(card:Card) -> void:
	disable_card_selection()
	
	if not last_card_for_player():
		card.show_cta_deck()
		card.card_cta_deck.selectable = true
		card.card_cta_deck.selected.connect(on_cta_deck_selected)
	
	if player_ref.hand.cards.is_empty():
		card.show_cta_main()
		card.card_cta_main.selectable = true
		card.card_cta_main.selected.connect(on_cta_main_selected)
		
	await get_tree().create_timer(0.1).timeout
	var pointableManager:PointableManager = get_tree().get_first_node_in_group("PointableManager")
	if pointableManager:
		pointableManager.point_to(card.card_cta_deck.pointable if not last_card_for_player() else card.card_cta_main.pointable)

func on_cta_deck_selected(_emitter:CardCta, card:Card) -> void:
	manage_deck_card_drop(card)
	disable_card_cta(card)
	if not cards.is_empty():
		enable_card_selection()
	else: 
		validate()

func on_cta_main_selected(_emitter:CardCta, card:Card) -> void:
	await manage_player_card_drop(card)
	disable_card_cta(card)
	if not cards.is_empty():
		enable_card_selection()
	else: 
		validate()

func disable_card_cta(card:Card) -> void:
	card.card_cta_deck.selectable = false
	if card.card_cta_deck.selected.is_connected(on_cta_deck_selected):
		card.card_cta_deck.selected.disconnect(on_cta_deck_selected)
	card.card_cta_main.selectable = false
	if card.card_cta_main.selected.is_connected(on_cta_main_selected):
		card.card_cta_main.selected.disconnect(on_cta_main_selected)
	card.hide_cta_deck()
	card.hide_cta_main()

func _pre_point() -> void:
	await get_tree().create_timer(0.1).timeout
	var pointableManager:PointableManager = get_tree().get_first_node_in_group("PointableManager")
	if pointableManager:
		pointableManager.pre_point_to_pointable()
