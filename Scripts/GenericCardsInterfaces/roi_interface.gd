class_name RoiInterface extends CardInterface


@onready var message: Message = $Message

var enemies:Array[Player]

func enter() -> void:
	super() # Execute parenter enter func
	enemies = player_ref.get_vulnerable_enemies()


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
	
	player_ref.hand.remove_card_from_hand(player_card)
	enemy.hand.remove_card_from_hand(enemy_card)
	
	player_ref.hand.add_card_to_hand(enemy_card)
	enemy.hand.add_card_to_hand(player_card)
	#player_ref.hand.cards[0] = enemy_card
	#enemy.hand.cards[0] = player_card
	await get_tree().create_timer(0.5).timeout
	
	
#endregion
