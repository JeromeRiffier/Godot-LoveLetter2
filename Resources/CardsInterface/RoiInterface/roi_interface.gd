class_name RoiInterface extends CardInterface


@onready var message: Message = $Message

var enemies:Array[EnemyAI]

func enter() -> void:
	super() # Execute parenter enter func
	player_ref.need_to_select_enemy.emit(true) ## Enable enemy selection
	enemies.assign(get_tree().get_nodes_in_group("Player").filter(func (enemy:Player) -> bool: return enemy != player_ref))
	connect_enemies_listeners()
	message.display_text("Qui?")
	
	#
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
	await animate_cards_exchange(enemy)
	validate()


func animate_cards_exchange(enemy:Player) -> void:
	var tween := create_tween()
	
	var player_card := player_ref.hand.cards[0]
	var enemy_card := enemy.hand.cards[0]
	
	var player_base_position:Vector2 = player_card.global_position
	var enemy_base_position:Vector2 = enemy_card.global_position

	tween.tween_property(player_card, "global_position", enemy_base_position, 0.5)
	tween.set_parallel()
	tween.tween_property(enemy_card, "global_position", player_base_position, 0.5)
	await tween.finished
	enemy_card.show_card()
	player_card.hide_card()
	
	player_ref.hand.cards[0] = enemy_card
	enemy.hand.cards[0] = player_card
	await get_tree().create_timer(0.5).timeout
	
	
#endregion
