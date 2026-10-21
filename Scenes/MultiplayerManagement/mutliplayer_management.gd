class_name Lobby extends Control

@onready var name_panel: PanelContainer = $CanvasLayer/CenterContainer/VBoxContainer/NamePanel
@onready var join_panel: PanelContainer = $CanvasLayer/CenterContainer/VBoxContainer/JoinPanel
@onready var host_panel: PanelContainer = $CanvasLayer/CenterContainer/VBoxContainer/HostPanel
@onready var player_list_panel: PanelContainer = $CanvasLayer/CenterContainer/VBoxContainer/PlayerListPanel
@onready var peers_list: GridContainer = $CanvasLayer/CenterContainer/VBoxContainer/PlayerListPanel/MarginContainer/VBoxContainer/PeersList
@onready var disconect_panel: PanelContainer = $CanvasLayer/CenterContainer/VBoxContainer/DisconectPanel
@onready var name_value: LineEdit = $CanvasLayer/CenterContainer/VBoxContainer/NamePanel/MarginContainer/GridContainer/NameValue
@onready var host_port: SpinBox = $CanvasLayer/CenterContainer/VBoxContainer/HostPanel/MarginContainer/VBoxContainer/GridContainer/HostPort
@onready var join_ip: LineEdit = $CanvasLayer/CenterContainer/VBoxContainer/JoinPanel/MarginContainer/VBoxContainer/Options/JoinIp
@onready var join_port: SpinBox = $CanvasLayer/CenterContainer/VBoxContainer/JoinPanel/MarginContainer/VBoxContainer/Options/JoinPort
@onready var start_panel: PanelContainer = $CanvasLayer/CenterContainer/VBoxContainer/StartPanel
@onready var start_button: Button = $CanvasLayer/CenterContainer/VBoxContainer/StartPanel/StartButton
@onready var ia_number: SpinBox = $CanvasLayer/CenterContainer/VBoxContainer/PanelContainer/MarginContainer/GridContainer/IaNumber


const MAX_PLAYERS: int = 5
const DEFAULT_PORT: int = 47218
var players :Dictionary[int, String] = {}   # peer_id -> nom
var my_name :String


var connected:bool = false:
	set(value):
		connected = value
		disconect_panel.visible = value
		player_list_panel.visible = value
		join_panel.visible = !value
		host_panel.visible = !value

signal players_changed

func _ready() -> void:
	
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	players_changed.connect(update_player_list)
	name_value.text = Constant.random_string(5)
	connected = false
	start_panel.visible = false

func host_game(port:int, player_name: String) -> void:
	if player_name != "":
		my_name = player_name
	var peer := ENetMultiplayerPeer.new()
	peer.create_server(port)
	multiplayer.multiplayer_peer = peer
	players[1] = my_name
	players_changed.emit()
	connected = true
	start_panel.visible = true

func join_game(ip: String, port:int, player_name: String) -> void:
	if player_name != "":
		my_name = player_name
	var peer := ENetMultiplayerPeer.new()
	peer.create_client(ip, port)
	multiplayer.multiplayer_peer = peer
	connected = true

func quit_game() -> void:
	if not multiplayer.is_server():
		multiplayer.multiplayer_peer.disconnect_peer(1) ##Discotnnect the player from the game
	else:
		start_panel.visible=false
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

func generate_player_list() -> Array[PlayerElement]:
	var list:Array[PlayerElement] = []
	for id:int in players.keys():
		var element := PlayerElement.new()
		element.id = id
		element.name = players[id]
		element.type = PlayerElement.PLAYER_TYPE.REAL
		list.append(element)
	for i in range(ia_number.value):
		var element := PlayerElement.new()
		element.id = randi()
		element.name = Constant.random_string(5)
		element.type = PlayerElement.PLAYER_TYPE.IA
		list.append(element)
	list.shuffle()
	return list


func _on_player_action(player:Player,_card:Card,action:PlayerAction) -> void:
	transmit_actions_to_peers.rpc(action.to_dict())

func update_player_list() -> void:
	for child in peers_list.get_children():
		child.queue_free()
	print(players)
	for player_id in players:
		var player_name := players[player_id]
		var node := Label.new()
		node.text = player_name
		peers_list.add_child(node)

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
	players[id] = player_name
	sync_players.rpc(players)

# Exécuté partout (serveur compris grâce à call_local), appelé par le serveur
@rpc("authority", "call_local", "reliable")
func sync_players(list: Dictionary) -> void:
	players = list
	players_changed.emit()

func _on_peer_disconnected(id: int) -> void:
	if multiplayer.is_server():
		players.erase(id)
		sync_players.rpc(players)

func _on_server_disconnected() -> void:
	players.clear()
	multiplayer.multiplayer_peer = null
	players_changed.emit()
#endregion 


#region Node events
func _on_host_button_pressed() -> void:
	@warning_ignore("narrowing_conversion")
	host_game(host_port.value,name_value.text)


func _on_join_button_pressed() -> void:
	@warning_ignore("narrowing_conversion")
	join_game(join_ip.text, join_port.value, name_value.text)


func _on_disconnect_button_pressed() -> void:
	quit_game()


func _on_start_button_pressed() -> void:
	var my_seed := "FixedSeed".hash() ## Find a way to generate the seed and transmit it to each peers
	var playersList := generate_player_list().map(func (element:PlayerElement) -> Dictionary: return element.to_dict())
	start_game.rpc(my_seed, playersList)
#endregion
