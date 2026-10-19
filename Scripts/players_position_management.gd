class_name PlayersPositionManagement extends Node2D



func position_players(players:Array[Player]) -> void:
	for i in range(players.size()):
		if players[i] is LocalPlayer:
			continue
		var new_position := Vector2(calculate_enemy_positions_x(i, players.size()-1), Constant.ENEMY_Y_POS)
		players[i].global_position = new_position

func calculate_enemy_positions_x(index: int, number_of_other_players:int) -> float:
	var total_width := number_of_other_players * Constant.ENEMY_WIDTH
	return get_tree().root.size.x /2.0 + index * Constant.ENEMY_WIDTH - total_width / 2.0 + (Constant.ENEMY_WIDTH / 2.0)
