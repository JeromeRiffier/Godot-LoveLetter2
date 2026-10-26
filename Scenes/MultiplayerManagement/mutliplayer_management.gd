class_name Lobby extends Control

const MAX_PLAYERS: int = 6
const DEFAULT_PORT: int = 47218
var my_name :String
var players:Array[PlayerElement]

var connected:bool = false:
	set(value):
		if value == connected:
			return
		connected = value
		connection_changed.emit(connected)

signal players_changed
signal connection_changed(is_connected:bool)
static var instance:Lobby
#region singleton
func _enter_tree() -> void:
	if instance != null and instance != self:
		queue_free()  # un doublon existe déjà
		return
	instance = self

func _exit_tree() -> void:
	if instance == self:
		instance = null
#endregion

func _ready() -> void:
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	connected = false

func host_game(port:int, player_name: String) -> void:
	if player_name != "":
		my_name = player_name
	var peer := ENetMultiplayerPeer.new()
	var error:= peer.create_server(port)
	if error:
		MessageManager.instance.display_text("Le serveur ne peut être créer")
		return
	multiplayer.multiplayer_peer = peer
	var element := PlayerElement.new()
	element.id = 1
	element.name = my_name
	element.type = PlayerElement.PLAYER_TYPE.REAL
	players = [element]
	players_changed.emit()
	connected = true

func join_game(ip: String, port:int, player_name: String) -> void:
	if player_name != "":
		my_name = player_name
	var peer := ENetMultiplayerPeer.new()
	var error:= peer.create_client(ip, port)
	if error:
		MessageManager.instance.display_text("Impossible de joindre la partie")
		print('canont connect')
		return
	multiplayer.multiplayer_peer = peer
	await get_tree().create_timer(0.3).timeout
	var status := peer.get_connection_status()
	if status == MultiplayerPeer.CONNECTION_CONNECTED:
		connected = true
	else: 
		multiplayer.multiplayer_peer.close()
		MessageManager.instance.display_text("Impossible de joindre la partie")
		
func quit_game() -> void:
	if not multiplayer.is_server():
		multiplayer.multiplayer_peer.disconnect_peer(1) ##Discotnnect the player from the game
	else:
		for peer_id in multiplayer.get_peers():
			multiplayer.multiplayer_peer.disconnect_peer(peer_id) 
		multiplayer.multiplayer_peer.close()
	connected = false

@rpc("any_peer", "call_local", "reliable")
func start_game(seed_key:int, players_list_dic:Array) -> void:
	print('Start game')
	seed(seed_key)
	var players_list : Array[PlayerElement] = []
	players_list.assign(
		players_list_dic.map(func (dicElement:Dictionary) -> PlayerElement: return PlayerElement.from_dict(dicElement))
	)
	GameManager.instance.start_game(players_list)
	for player in GameManager.instance.players:
		if player is LocalPlayer:
			if not player.has_played.is_connected(_on_player_action):
				player.has_played.connect(_on_player_action)

@rpc("any_peer", "call_remote", "reliable")
func transmit_actions_to_peers(action_dic:Dictionary) -> void:
	var action:PlayerAction = PlayerAction.from_dict(action_dic)
	var player_concerned_index :int = GameManager.instance.players.find_custom(func (player:Player) -> bool: return player.id == action.player_peer_id)
	if player_concerned_index == -1:
		print('sompething whent horrybly wrong')
	var player_concerned :Player = GameManager.instance.players[player_concerned_index]
	player_concerned.reflect_action(action)
	print("ok", action)


func _on_player_action(_player:Player,_card:Card,action:PlayerAction) -> void:
	transmit_actions_to_peers.rpc(action.to_dict())



#region Network events
# Côté client : une fois connecté, on envoie son nom au serveur
func _on_connected_to_server() -> void:
	register_player.rpc_id(1, my_name)

# Exécuté sur le serveur, appelé par un client
@rpc("any_peer", "reliable")
func register_player(player_name: String) -> void:
	if not multiplayer.is_server():
		return
	var id := multiplayer.get_remote_sender_id()
	var element := PlayerElement.new()
	element.id = id
	element.name = player_name
	element.type = PlayerElement.PLAYER_TYPE.REAL
	players.append(element)
	sync_players.rpc(players.map(func (new_player:PlayerElement) -> Dictionary:return  new_player.to_dict()))

func register_ai() -> void:
	if players.size() >= MAX_PLAYERS:
		return
	var element := PlayerElement.new()
	element.id = randi()
	element.name = Constant.random_string(5)
	element.type = PlayerElement.PLAYER_TYPE.IA
	players.append(element)
	sync_players.rpc(players.map(func (new_player:PlayerElement) -> Dictionary:return  new_player.to_dict()))

func kick_player(player_index:int) -> void:
	if not multiplayer.is_server():
		return
	print('kicking %s' % players[player_index].name)
	if players[player_index].type == PlayerElement.PLAYER_TYPE.IA:
		players.pop_at(player_index)
		sync_players.rpc(players.map(func (new_player:PlayerElement) -> Dictionary:return  new_player.to_dict()))
	else:
		multiplayer.multiplayer_peer.disconnect_peer(players[player_index].id)

	
# Exécuté partout (serveur compris grâce à call_local), appelé par le serveur
@rpc("authority", "call_local", "reliable")
func sync_players(list_dic: Array) -> void:
	players.assign(
		list_dic.map(func (dicElement:Dictionary) -> PlayerElement: return PlayerElement.from_dict(dicElement))
	)
	players_changed.emit()

func _on_peer_disconnected(id: int) -> void:
	if multiplayer.is_server():
		var index := players.find_custom(func (player:PlayerElement) -> bool: return player.id  == id)
		if index != -1:
			players.pop_at(index)
		sync_players.rpc(players.map(func (new_player:PlayerElement) -> Dictionary:return  new_player.to_dict()))
	if multiplayer.get_unique_id() == id:
		multiplayer.multiplayer_peer = null
		connected = false
		players.clear()
		players_changed.emit()
	
func _on_server_disconnected() -> void:
	multiplayer.multiplayer_peer = null
	connected = false
	players.clear()
	players_changed.emit()
#endregion 


#region Node events
func _on_start_button_pressed() -> void:
	var my_seed := "FixedSeed".hash() ## Find a way to generate the seed and transmit it to each peers
	var playersList := players.map(func (element:PlayerElement) -> Dictionary: return element.to_dict())
	var id = multiplayer.get_unique_id()
	var is_server = multiplayer.is_server()
	var peerss = multiplayer.get_peers()
	start_game.rpc(my_seed, playersList)
#endregion
