class_name GardeInterface extends CardInterface

@onready var card_selection_tool: CardSelectionTool = $CardSelectionTool
@onready var label: Label = $Label

var enemy_selected:Player = null
var card_selected:CardInfos = null
var enemies:Array[EnemyAI]


func enter() -> void:
	super() # Execute parenter enter func
	enemy_selected = null
	card_selected = null
	display_text("Qui?")
	player_ref.need_to_select_enemy.emit(true) ## Enable enemy selection
	print("wait for enemy selection")
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
	await display_text("Qu'elle carte?")
	card_selection_tool.activate()
#endregion


func _on_card_selection_tool_card_selected(card: CardInfos) -> void:
	card_selected = card
	check_result()

func check_result() -> void:
	if enemy_selected.hand.cards[0].infos == card_selected:
		print("kill ",enemy_selected)
		enemy_selected.kill()
		await display_text("Bravo!")
	else:
		await display_text("Nope!")
	validate()


func display_text(text:String) -> void:
	label.add_theme_color_override("font_color", Color.TRANSPARENT)
	label.text = text
	label.size = get_tree().root.size
	label.global_position = Vector2.ZERO
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_EXPO)
	tween.tween_property(label, "theme_override_colors/font_color", Color.WHITE, 1.5)
	await tween.finished
	label.add_theme_color_override("font_color", Color.TRANSPARENT)
