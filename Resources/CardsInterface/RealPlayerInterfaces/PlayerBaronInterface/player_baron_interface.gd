class_name PlayerBaronInterface extends BaronInterface

var enemies:Array[EnemyAI]

func enter() -> void:
	super() # Execute parenter enter func
	player_ref.need_to_select_enemy.emit(true) ## Enable enemy selection
	enemies.assign(player_ref.get_vulnerable_enemies())
	message.display_text("Qui?")
	connect_enemies_listeners()
	
#region Enemy selection listeners
func connect_enemies_listeners() -> void:
	for enemy in enemies:
		enemy.enemy_selected.connect(select_enemy)
func disconnect_enemies_listeners() -> void:
	for enemy in enemies:
		enemy.enemy_selected.disconnect(select_enemy)
#endregion

func select_enemy(enemy:Player) -> void:
	disconnect_enemies_listeners()
	player_ref.need_to_select_enemy.emit(false) ## Disable enemy selection
	var player_card:Card = player_ref.hand.cards[0]
	var enemy_card:Card = enemy.hand.cards[0]
	enemy_card.show_card()
	await animate_cards_to_center(player_card, enemy_card)
	manage_result(enemy)
