class_name EnemyAI extends Player

const ENEMY_MASK:int = 8

signal enemy_selected

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			var space_state := get_world_2d().direct_space_state
			var parameters := PhysicsPointQueryParameters2D.new()
			parameters.position = get_global_mouse_position()
			parameters.collide_with_areas = true
			parameters.collision_mask = ENEMY_MASK
			var colision_result := space_state.intersect_point(parameters)
			if not colision_result.is_empty() && colision_result[0].collider.get_parent() == self:
				print("Enemy clicked ", name)
				enemy_selected.emit()

func takeTurn():
	await get_tree().create_timer(0.2).timeout
	
	## TODO to be reworked
	var card_to_play:Card = hand.cards[0]
	if not is_card_playable(card_to_play):
		card_to_play = hand.cards[1]
	## END TODO
	
	await animate_card_to_slot(card_to_play)
	hand.remove_card_from_hand(card_to_play)
	card_slot.receive_card(card_to_play)

	card_to_play.process_mode = Node.PROCESS_MODE_DISABLED ## I suppose disabling the full node will work as fine as disabling the colisionShape 
	has_played.emit()

func animate_card_to_slot(card:Card) -> void:
	var tween = create_tween()
	tween.tween_property(card, "global_position", card_slot.global_position, 0.2 )
	await tween.finished
