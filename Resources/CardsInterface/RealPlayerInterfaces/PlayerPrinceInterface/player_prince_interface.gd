class_name PlayerPrinceInterface extends PrinceInterface



func enter() -> void:
	super() # Execute parenter enter func
	player_ref.need_to_select_enemy.emit(true) ## Enable enemy selection
	connect_enemies_listeners()
	message.display_text("Qui?")
	
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
	enemy.discard(enemy.hand.cards[0])
	validate()
#endregion
