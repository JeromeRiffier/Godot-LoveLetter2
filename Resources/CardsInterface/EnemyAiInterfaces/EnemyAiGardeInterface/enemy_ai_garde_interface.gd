class_name EnemyAIGardeInterface extends GardeInterface

func enter() -> void:
	super() # Execute parenter enter func
	if enemies.is_empty():
		message.display_text("Impossible")
		validate()
		return
	selected_enemy = enemies.pick_random()
	card_selected = Constant.CardTypesWithoutGuard.pick_random()
	await message.display_text("%s à choisis %s et tente %s" % [player_ref.name, selected_enemy.name, card_selected.title])
	check_result()
