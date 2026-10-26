class_name SidePanel extends Control

@onready var option_modal: OptionModal = $OptionModal
@onready var player_list_value_panel: ValuePanel = $PanelContainer/MarginContainer/VBoxContainer/PlayerListValuePanel
@onready var player_name_label: Label = $PanelContainer/MarginContainer/VBoxContainer/PlayerInfos/GridContainer/PlayerNameLabel
@onready var panel_container: PanelContainer = $PanelContainer

func _ready() -> void:
	reset_labels()
	var lobby := Lobby.instance
	if lobby: 
		lobby.players_changed.connect(_on_lobby_players_changed)
		lobby.connection_changed.connect(_on_lobby_connection_changed)
	resized.connect(_on_self_resized)
	var gameManager := GameManager.instance
	if gameManager: 
		gameManager.game_start.connect(close_all_modals)

func reset_labels() -> void:
	player_list_value_panel.value = ""

func close_all_modals() -> void:
	option_modal.exit()

func _on_option_button_pressed() -> void:
	option_modal.enter()

func _on_lobby_players_changed() -> void:
	player_list_value_panel.value = "\n".join(Lobby.instance.players.map( func (player:PlayerElement) -> String:return player.name))
	print(player_list_value_panel.value)

func _on_lobby_connection_changed(connected:bool) -> void:
	var lobby := Lobby.instance
	if lobby and connected:
		player_name_label.text = lobby.my_name

## Seems to not working
func _on_self_resized() -> void:
	panel_container.set_instance_shader_parameter("node_width", self.size.x)
