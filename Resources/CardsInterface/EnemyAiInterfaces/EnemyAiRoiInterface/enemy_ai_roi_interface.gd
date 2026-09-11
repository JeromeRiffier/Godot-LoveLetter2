class_name EnemyAIRoiInterface extends RoiInterface


func enter() -> void:
	super() # Execute parenter enter func
	if enemies.is_empty():
		message.display_text("Impossible")
		validate()
		return
	var selected_enemy:Player = enemies.pick_random()
	await animate_cards_exchange(selected_enemy)
	validate()
