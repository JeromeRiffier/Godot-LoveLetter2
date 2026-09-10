class_name GardeInterface extends CardInterface

@onready var card_selection_tool: CardSelectionTool = $CardSelectionTool
@onready var message: Message = $Message

var enemy_selected:Player = null
var card_selected:CardInfos = null
var enemies:Array[EnemyAI]


func enter() -> void:
	super() # Execute parenter enter func
	enemy_selected = null
	card_selected = null
	message.display_text("Qui?")
	player_ref.need_to_select_enemy.emit(true) ## Enable enemy selection
	enemies.assign(get_tree().get_nodes_in_group("Player").filter(func (enemy:Player) -> bool: return enemy != player_ref))
	connect_enemies_listeners()

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
	enemy_selected = enemy
	print("Guard selected ",enemy_selected)
	await message.display_text("Qu'elle carte?")
	card_selection_tool.activate()
#endregion


func _on_card_selection_tool_card_selected(card: CardInfos) -> void:
	card_selected = card
	check_result()

func check_result() -> void:
	if enemy_selected.hand.cards[0].infos == card_selected:
		print("kill ",enemy_selected)
		enemy_selected.kill()
		await message.display_text("Bravo!")
	else:
		await message.display_text("Nope!")
	validate()
