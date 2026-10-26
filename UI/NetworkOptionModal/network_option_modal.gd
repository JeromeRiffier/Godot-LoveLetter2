class_name NetworkOptionModal extends TabContainer

signal close

@onready var host_port: SpinBox = $HostContainer/VBoxContainer/HostPanel/MarginContainer/VBoxContainer/GridContainer/HostPort
@onready var host_name_value: LineEdit = $HostContainer/VBoxContainer/NamePanel/MarginContainer/GridContainer/NameValue

@onready var join_ip: LineEdit = $JoinContainer/VBoxContainer/JoinPanel/MarginContainer/Options/JoinIp
@onready var join_port: SpinBox = $JoinContainer/VBoxContainer/JoinPanel/MarginContainer/Options/JoinPort
@onready var join_name_value: LineEdit = $JoinContainer/VBoxContainer/NamePanel/MarginContainer/GridContainer/NameValue
@onready var players_item_list: ItemList = $HostingContainer/VBoxContainer/PlayersItemList
@onready var action_buttons_container: GridContainer = $HostingContainer/VBoxContainer/ActionButtonsContainer
@onready var kick_player_button: Button = $HostingContainer/VBoxContainer/ActionButtonsContainer/KickPlayerPanel/KickPlayerButton

func _ready() -> void:
	players_item_list.clear()
	_on_lobby_connection_changed(false)
	if multiplayer.get_unique_id() != 1:
		action_buttons_container.queue_free()
	var lobby := Lobby.instance
	if lobby: 
		lobby.players_changed.connect(_on_lobby_players_changed)
		lobby.connection_changed.connect(_on_lobby_connection_changed)

func _on_lobby_players_changed() -> void:
	players_item_list.clear()
	for player in Lobby.instance.players:
		var icon:Texture2D
		match player.type:
			PlayerElement.PLAYER_TYPE.REAL:
				if player.id == multiplayer.get_unique_id():
					icon = preload("uid://dtndun643t4sg")
				else:
					icon = preload("uid://c1douwtxlfxvq")
			PlayerElement.PLAYER_TYPE.IA:
				icon = preload("uid://bt7vxpwel6ll")
		players_item_list.add_item(
			player.name,
			icon,
			multiplayer.get_unique_id() == 1 and player.id != 1 ##Seul l'host peux kické des joueurs et ne peux pas s'auto-kick^^
		)

func _on_lobby_connection_changed(connected:bool) -> void:
	if connected:
		set_tab_hidden(2, false)
		current_tab = 2
		set_tab_hidden(0, true)
		set_tab_hidden(1, true)
	else:
		set_tab_hidden(0, false)
		set_tab_hidden(1, false)
		current_tab = 0
		set_tab_hidden(2, true)

func _on_add_ai_button_pressed() -> void:
	var lobby := Lobby.instance
	if not lobby: return
	lobby.register_ai()

func _on_players_item_list_item_selected(index: int) -> void:
	print('_on_players_item_list_item_selected ',index)
	kick_player_button.disabled = false

func _on_kick_player_button_pressed() -> void:
	var selecteds :=players_item_list.get_selected_items()
	if selecteds.is_empty():
		return
	var lobby := Lobby.instance
	if not lobby: return
	lobby.kick_player(selecteds[0])

func _on_disconnect_button_pressed() -> void:
	var lobby := Lobby.instance
	if not lobby: return
	lobby.quit_game()

func _on_close_button_pressed() -> void:
	close.emit()

func _on_host_button_pressed() -> void:
	var lobby := Lobby.instance
	if not lobby: return
	lobby.host_game(int(host_port.value), host_name_value.text )

func _on_join_button_pressed() -> void:
	var lobby := Lobby.instance
	if not lobby: return
	lobby.join_game(join_ip.text, int(join_port.value), join_name_value.text)


func _on_start_game_button_pressed() -> void:
	var lobby := Lobby.instance
	if not lobby: return
	lobby._on_start_button_pressed()
	
