class_name PlayerChancelierInterface extends ChancelierInterface


func _ready() -> void:
	var pointableManager:PointableManager = get_tree().get_first_node_in_group("PointableManager")
	if pointableManager:
		pointableManager.changed_mode.connect(handle_pointable_controller_mode_change)

func enter() -> void:
	await super() # Execute parenter enter func
	message.display_text("Fait ton choix")
	enable_card_selection()
	enable_cards_listener()
	
func enable_cards_listener() -> void:
	for card in cards:
		enable_card_listener(card)
func enable_card_listener(card:Card) -> void:
	card.stopping_drag.connect(card_stopped_dragging)

func disable_cards_listener() -> void:
	for card in cards:
		disable_card_listener(card)
func disable_card_listener(card:Card) -> void:
	card.stopping_drag.disconnect(card_stopped_dragging)

func card_stopped_dragging(card:Card) -> void:
	var deck := detect_deck_collision()
	var player := detect_player_collision()
	if player:
		manage_player_card_drop(card)
	elif deck:
		manage_deck_card_drop(card)
	else:
		card.global_position = card.position_in_hand
	if cards.is_empty():
		validate()


func manage_player_card_drop(card:Card) -> void:
	if player_ref.hand.cards.is_empty():
		cards.erase(card)
		await player_ref.draw_card(card)
		disable_card_listener(card)
	else: 
		message.display_text("Il y a deja une carte dans ton deck")

func manage_deck_card_drop(card:Card) -> void:
	if last_card_for_player():
		message.display_text("La derniere carte et pour toi")
	else:
		player_ref.return_card.emit(card)
		cards.erase(card)
		disable_card_listener(card)



## return true if there is only one card left to choose and the player haven't got his
func last_card_for_player() -> bool:
	return cards.size() == 1 && player_ref.hand.cards.is_empty()



#region dragging collision management
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
#endregion

#region Controller mode management
var card_selected:Card
func handle_pointable_controller_mode_change(is_controller_mode:bool) -> void:
	if not is_active:
		return
	if not is_controller_mode and card_selected:
		disable_card_cta(card_selected)
		disable_card_selection()
		card_selected = null
	if is_controller_mode and not card_selected:
		enable_card_selection()

func enable_card_selection() -> void:
	for card in cards:
		card.selectable = true
		if not card.selected.is_connected(manage_card_selected):
			card.selected.connect(manage_card_selected)
	_pre_point()

func disable_card_selection() -> void:
	for card in cards:
		card.selectable = false
		if card.selected.is_connected(manage_card_selected):
			card.selected.disconnect(manage_card_selected)

func manage_card_selected(card:Card) -> void:
	card_selected = card
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
#endregion
