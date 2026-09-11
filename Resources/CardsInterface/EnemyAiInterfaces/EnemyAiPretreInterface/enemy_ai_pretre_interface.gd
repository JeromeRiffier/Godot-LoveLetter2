class_name EnemyAIPretreInterface extends CardInterface


@onready var message: Message = $Message

var enemies:Array[Player]

func enter() -> void:
	super() # Execute parenter enter func
	enemies = player_ref.get_vulnerable_enemies()
	if enemies.is_empty():
		message.display_text("Impossible")
		validate()
		return
	var selected_enemy :Player = enemies.pick_random()
	message.display_text("%s regarde la carte de %s" % [player_ref.name, selected_enemy.name])
	await get_tree().create_timer(2).timeout
	validate()
	
