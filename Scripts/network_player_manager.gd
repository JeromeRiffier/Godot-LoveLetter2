class_name NetworkPlayerManager extends Node

const NETWORK_PLAYER = preload("uid://i32aqpnvupt5")

var network_players: Array[NetworkPlayer]

func spawn_enemies(count:int) -> Array[NetworkPlayer]:
	for i in range(count):
		var enemy:AiPlayer = NETWORK_PLAYER.instantiate()
		add_child(enemy)
		network_players.append(enemy)
	position_enemies()
	return network_players

func position_enemies() -> void:
	for i in range(network_players.size()):
		var new_position := Vector2(calculate_enemy_positions_x(i), Constant.ENEMY_Y_POS)
		network_players[i].global_position = new_position

func calculate_enemy_positions_x(index: int) -> float:
	var total_width := network_players.size() * Constant.ENEMY_WIDTH
	return get_tree().root.size.x /2.0 + index * Constant.ENEMY_WIDTH - total_width / 2.0 + (Constant.ENEMY_WIDTH / 2.0)
