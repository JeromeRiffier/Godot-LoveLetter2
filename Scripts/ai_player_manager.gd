class_name AiPlayerManager extends Node

const AI_PLAYER = preload("uid://brqs2imb2p7gr")

var ai_players: Array[AiPlayer]

## Deprecated 
func spawn_ai_players(count:int) -> Array[AiPlayer]:
	for i in range(count):
		var enemy:AiPlayer = AI_PLAYER.instantiate()
		add_child(enemy)
		ai_players.append(enemy)
	#position_ai_players()
	return ai_players

func spawn_ai_player(playerData:PlayerElement) -> AiPlayer:
	var enemy:AiPlayer = AI_PLAYER.instantiate()
	enemy.name = playerData.name
	enemy.id = playerData.id
	add_child(enemy)
	ai_players.append(enemy)
	return enemy



func position_ai_players() -> void:
	for i in range(ai_players.size()):
		var new_position := Vector2(calculate_enemy_positions_x(i), Constant.ENEMY_Y_POS)
		ai_players[i].global_position = new_position

func calculate_enemy_positions_x(index: int) -> float:
	var total_width := ai_players.size() * Constant.ENEMY_WIDTH
	return get_tree().root.size.x /2.0 + index * Constant.ENEMY_WIDTH - total_width / 2.0 + (Constant.ENEMY_WIDTH / 2.0)
