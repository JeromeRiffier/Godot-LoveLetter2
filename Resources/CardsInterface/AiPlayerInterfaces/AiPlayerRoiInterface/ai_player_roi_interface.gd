class_name AiPlayerRoiInterface extends RoiInterface


func enter() -> void:
	super() # Execute parenter enter func
	if enemies.is_empty():
		await MessageManager.instance.display_text("Impossible")
		validate()
		return
	var selected_enemy:Player = enemies.pick_random()
	await animate_cards_exchange(selected_enemy)
	validate()
