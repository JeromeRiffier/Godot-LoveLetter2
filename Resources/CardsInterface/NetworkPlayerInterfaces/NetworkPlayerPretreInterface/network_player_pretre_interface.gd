class_name NetworkPlayerPretreInterface extends CardInterface

var enemies:Array[Player]

func enter(action:PlayerAction = null) -> void:
	super() # Execute parenter enter func
	enemies = player_ref.get_vulnerable_enemies()
	if enemies.is_empty():
		await MessageManager.instance.display_text("Impossible")
		validate()
		return
	var selected_enemy :Player = enemies[action.enemy_selected_index]
	MessageManager.instance.display_text("%s regarde la carte de %s" % [player_ref.name, selected_enemy.name])
	await get_tree().create_timer(2).timeout
	validate()
	
