class_name EnemyManager extends Node

const ENEMY_AI = preload("uid://brqs2imb2p7gr")

var enemies: Array[EnemyAI]

func spawn_enemies(count:int) -> Array[EnemyAI]:
	for i in range(count):
		var enemy:EnemyAI = ENEMY_AI.instantiate()
		add_child(enemy)
		enemies.append(enemy)
	position_enemies()
	return enemies

func position_enemies() -> void:
	for i in range(enemies.size()):
		var new_position := Vector2(calculate_enemy_positions_x(i), Constant.ENEMY_Y_POS)
		enemies[i].global_position = new_position

func calculate_enemy_positions_x(index: int) -> float:
	var total_width := enemies.size() * Constant.ENEMY_WIDTH
	return get_tree().root.size.x /2.0 + index * Constant.ENEMY_WIDTH - total_width / 2.0 + (Constant.ENEMY_WIDTH / 2.0)
