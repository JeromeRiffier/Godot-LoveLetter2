class_name PlayersPositionManagement extends Node2D


## Since we do not want to fuck up the order display of the enemies and the local player will always be displayed on the bottom of the screen: [br]
## First, we rotate the players array to put the local player first (so that it is not in the middle of the player base)[br]
## Then, we position all the other players neatly on top[br]
## This result in all players turn behing logical but the first to play is not necessarly the first in the line
func position_players(players:Array[Player]) -> void:
	var shiffted_array :=shift_local_player_to_first_pos(players)
	var non_local_players := _get_non_local_players(shiffted_array)
	for i in range(non_local_players.size()):
		var new_position := Vector2(calculate_enemy_positions_x(i, non_local_players.size()-1), Constant.ENEMY_Y_POS)
		non_local_players[i].global_position = new_position

func calculate_enemy_positions_x(index: int, number_of_other_players:int) -> float:
	var total_width := number_of_other_players * Constant.ENEMY_WIDTH
	return get_tree().root.size.x /2.0 + index * Constant.ENEMY_WIDTH - total_width / 2.0 + (Constant.ENEMY_WIDTH / 2.0)

func _get_non_local_players(players:Array[Player]) -> Array[Player]:
	return players.filter(func (player:Player) -> bool: return player is not LocalPlayer)

func shift_local_player_to_first_pos(players:Array[Player]) -> Array[Player]:
	var local_player_index :int= players.find_custom(func (player:Player) -> bool: return player is LocalPlayer)
	if local_player_index == -1:
		print("error local player not founded")
	var shifted_array :Array[Player] = players.slice(local_player_index)
	shifted_array.append_array(players.slice(0,local_player_index))
	return shifted_array
