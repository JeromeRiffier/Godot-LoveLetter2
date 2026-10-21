class_name AiPlayerGardeInterface extends GardeInterface

func enter() -> void:
	super() # Execute parenter enter func
	if enemies.is_empty():
		await MessageManager.instance.display_text("Impossible")
		validate()
		return
	selected_enemy = enemies.pick_random()
	selected_card = Constant.CardTypesWithoutGuard.pick_random()
	await MessageManager.instance.display_text("%s à choisis %s et tente %s" % [player_ref.name, selected_enemy.name, selected_card.title])
	check_result()
