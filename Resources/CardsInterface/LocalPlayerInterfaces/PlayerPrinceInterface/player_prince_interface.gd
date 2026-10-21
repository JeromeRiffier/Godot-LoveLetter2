class_name LocalPlayerPrinceInterface extends PrinceInterface

func enter() -> void:
	super() # Execute parenter enter func
	if enemies.is_empty():
		await MessageManager.instance.display_text("Tout les joueurs restant sont protégé")
		return manage_unplayable_case()
	player_ref.need_to_select_enemy.emit(true) ## Enable enemy selection
	connect_enemies_listeners()
	await MessageManager.instance.display_text("Qui?")
	pre_point_enemy()
	
#region Enemy selection
func connect_enemies_listeners() -> void:
	for enemy in enemies:
		enemy.enemy_selected.connect(select_enemy)
func disconnect_enemies_listeners() -> void:
	for enemy in enemies:
		enemy.enemy_selected.disconnect(select_enemy)

func select_enemy(enemy:Player) -> void:
	player_action.enemy_selected_index = GameManager.instance.players.find(enemy)
	disconnect_enemies_listeners()
	player_ref.need_to_select_enemy.emit(false) ## Disable enemy selection
	enemy.discard(enemy.hand.cards[0])
	validate()
#endregion
