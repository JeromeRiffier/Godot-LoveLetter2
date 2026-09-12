class_name ChancelierInterface extends CardInterface

@onready var message: Message = $Message

var cards:Array[Card]


func enter() -> void:
	super() # Execute parenter enter func
	print('ChancelierInterface')
	player_ref.need_card.emit(player_ref)
	player_ref.need_card.emit(player_ref)
	await player_ref.hand.card_repositioned
	for i in range(player_ref.hand.cards.size()):
		cards.append(player_ref.hand.cards[0])
		player_ref.hand.remove_card_from_hand(player_ref.hand.cards[0])
		await animate_cards_to_center()
	
#region Card positioning
func animate_cards_to_center() -> void:
	var center_y := (get_tree().root.size.y /2.0) +  80.0
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
