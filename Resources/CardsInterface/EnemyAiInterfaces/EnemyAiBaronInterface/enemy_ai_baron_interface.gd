class_name EnemyAIBaronInterface extends CardInterface



@onready var message: Message = $Message

var enemies:Array[EnemyAI]
var cards :Array[Card]

func enter() -> void:
	super() # Execute parenter enter func
	cards = []
	player_ref.need_to_select_enemy.emit(true) ## Enable enemy selection
	enemies.assign(get_tree().get_nodes_in_group("Player").filter(func (enemy:Player) -> bool: return enemy != player_ref))
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
	var player_card:Card = player_ref.hand.cards[0]
	var enemy_card:Card = enemy.hand.cards[0]
	enemy_card.show_card()
	await animate_cards_to_center(player_card, enemy_card)
	if player_card.infos.value > enemy_card.infos.value:
		enemy.kill()
		await message.display_text("Win!")
		enemy.discard(enemy_card)
		player_ref.hand.update_hand_positions()
	elif player_card.infos.value < enemy_card.infos.value:
		player_ref.kill()
		await message.display_text("Lost!")
		player_ref.discard(player_card)
		enemy.hand.update_hand_positions()
		enemy_card.hide_card()
	else:
		await message.display_text("Ex aequo..")
		player_ref.hand.update_hand_positions()
		enemy.hand.update_hand_positions()
		enemy_card.hide_card()

	await get_tree().create_timer(1).timeout
	validate()


#endregion

#region Card positioning
func animate_cards_to_center(player_card:Card,enemy_card:Card) -> void:
	var center_y := (get_tree().root.size.y /2.0) +  80.0
	cards.assign([player_card, enemy_card])
	for i in range(cards.size()):
		var new_position =  Vector2(calculate_card_positions_x(i), center_y)
		var card := cards[i]
		card.position_in_hand = new_position
		await animate_card_to_position(card, new_position)


func calculate_card_positions_x(index:int) -> float:
	var total_width := cards.size() * Constant.CARD_WIDTH
	var x_offset := get_tree().root.size.x /2.0 + index * Constant.CARD_WIDTH - total_width / 2.0 + (Constant.CARD_WIDTH / 2.0)
	return x_offset
func animate_card_to_position(card:Card, new_position:Vector2) -> void:
	var tween = create_tween()
	tween.tween_property(card, "global_position", new_position, 0.3)
	await tween.finished
#endregion
