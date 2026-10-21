class_name NetworkPlayerGardeInterface extends GardeInterface

func enter(action:PlayerAction = null) -> void:
	super() # Execute parenter enter func
	if enemies.is_empty():
		message.display_text("Impossible")
		validate()
		return
	selected_enemy = GameManager.instance.players[action.enemy_selected_index]
	selected_card = Constant.CardTypes[action.card_type_selected_index]
	await message.display_text("%s à choisis %s et tente %s" % [player_ref.name, selected_enemy.name, selected_card.title])
	check_result()
