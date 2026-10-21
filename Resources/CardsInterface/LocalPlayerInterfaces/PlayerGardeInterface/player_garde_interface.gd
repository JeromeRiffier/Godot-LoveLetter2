class_name LocalPlayerGardeInterface extends GardeInterface

@onready var card_selection_tool: CardSelectionTool = $CardSelectionTool

func enter() -> void:
	super() # Execute parenter enter func
	if enemies.is_empty():
		await MessageManager.instance.display_text("Tout les joueurs restant sont protégé")
		return manage_unplayable_case()
	await MessageManager.instance.display_text("Qui?")
	player_ref.need_to_select_enemy.emit(true) ## Enable enemy selection
	connect_enemies_listeners()
	pre_point_enemy()

#region Enemy selection
func connect_enemies_listeners() -> void:
	for enemy in enemies:
		enemy.enemy_selected.connect(select_enemy)
func disconnect_enemies_listeners() -> void:
	for enemy in enemies:
		enemy.enemy_selected.disconnect(select_enemy)

func select_enemy(enemy:Player) -> void:
	disconnect_enemies_listeners()
	player_ref.need_to_select_enemy.emit(false) ## Disable enemy selection
	selected_enemy = enemy
	await MessageManager.instance.display_text("Qu'elle carte?")
	card_selection_tool.activate()
#endregion


func _on_card_selection_tool_selected_card(card: CardInfos) -> void:
	selected_card = card
	check_result()
