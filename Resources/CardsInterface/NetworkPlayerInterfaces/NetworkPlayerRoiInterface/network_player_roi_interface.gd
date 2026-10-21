class_name NetworkPlayerRoiInterface extends RoiInterface

func enter(action:PlayerAction = null) -> void:
	super() # Execute parenter enter func
	if enemies.is_empty():
		await MessageManager.instance.display_text("Impossible")
		validate()
		return
	var selected_enemy:Player = enemies[action.enemy_selected_index]
	await animate_cards_exchange(selected_enemy)
	validate()
