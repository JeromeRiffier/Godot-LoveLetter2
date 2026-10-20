class_name NetworkPlayerManager extends Node

const NETWORK_PLAYER = preload("uid://i32aqpnvupt5")

var network_players: Array[NetworkPlayer]
##Deprecated
func spawn_network_players() -> Array[NetworkPlayer]:
	print("spawn_network_players ",multiplayer.get_unique_id(),multiplayer.get_peers())
	for peer in multiplayer.get_peers():
		if peer == multiplayer.get_unique_id():
			continue ##Never append it seems that get_peers return only the other peers
		var networkPlayer:NetworkPlayer = NETWORK_PLAYER.instantiate()
		networkPlayer.peer_id  = peer
		add_child(networkPlayer)
		network_players.append(networkPlayer)
	#position_network_players()
	return network_players

func spawn_network_player(playerData:PlayerElement) -> NetworkPlayer:
	var networkPlayer:NetworkPlayer = NETWORK_PLAYER.instantiate()
	networkPlayer.id  = playerData.id
	networkPlayer.name  = playerData.name
	add_child(networkPlayer)
	network_players.append(networkPlayer)
	return networkPlayer

func position_network_players() -> void:
	for i in range(network_players.size()):
		var new_position := Vector2(calculate_enemy_positions_x(i), Constant.ENEMY_Y_POS)
		network_players[i].global_position = new_position

func calculate_enemy_positions_x(index: int) -> float:
	var total_width := network_players.size() * Constant.ENEMY_WIDTH
	return get_tree().root.size.x /2.0 + index * Constant.ENEMY_WIDTH - total_width / 2.0 + (Constant.ENEMY_WIDTH / 2.0)
