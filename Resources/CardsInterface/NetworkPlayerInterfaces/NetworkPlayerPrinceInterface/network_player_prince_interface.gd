class_name NetworkPlayerPrinceInterface extends PrinceInterface


func enter(action:PlayerAction = null) -> void:
	super() # Execute parenter enter func
	if enemies.is_empty():
		await MessageManager.instance.display_text("Impossible")
		validate()
		return
	var selected_enemy:Player = enemies[action.enemy_selected_index]
	await MessageManager.instance.display_text("%s a choisis %s, jette ta carte" % [player_ref.name, selected_enemy.name])
	await selected_enemy.discard(selected_enemy.hand.cards[0])
	validate()
	
