class_name PlayerGardeInterface extends GardeInterface

@onready var card_selection_tool: CardSelectionTool = $CardSelectionTool

func enter() -> void:
	super() # Execute parenter enter func
	message.display_text("Qui?")
	player_ref.need_to_select_enemy.emit(true) ## Enable enemy selection
	connect_enemies_listeners()

#region Enemy selection
func connect_enemies_listeners() -> void:
	for enemy in enemies:
		enemy.selected_enemy.connect(select_enemy)
func disconnect_enemies_listeners() -> void:
	for enemy in enemies:
		enemy.selected_enemy.disconnect(select_enemy)

func select_enemy(enemy:Player) -> void:
	disconnect_enemies_listeners()
	player_ref.need_to_select_enemy.emit(false) ## Disable enemy selection
	selected_enemy = enemy
	print("Guard selected ",selected_enemy)
	await message.display_text("Qu'elle carte?")
	card_selection_tool.activate()
#endregion


func _on_card_selection_tool_card_selected(card: CardInfos) -> void:
	card_selected = card
	check_result()
