class_name EnemyAIBaronInterface extends BaronInterface


func enter() -> void:
	super() # Execute parenter enter func
	var enemies := player_ref.get_vulnerable_enemies()
	if enemies.is_empty():
		message.display_text("Impossible")
		validate()
		return
	var selected_enemy:Player = enemies.pick_random()
	await message.display_text("%s à choisis %s" % [player_ref.name, selected_enemy.name])
	await animate_cards_to_center(player_ref.hand.cards[0], selected_enemy.hand.cards[0])
	manage_result(selected_enemy)
