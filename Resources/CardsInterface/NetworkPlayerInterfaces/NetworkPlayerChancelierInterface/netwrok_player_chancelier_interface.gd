class_name NetworkPlayerChancelierInterface extends ChancelierInterface



func enter(action:PlayerAction = null) -> void:
	await super() # Execute parenter enter func
	if action.chancelier_card_destinations.first == Constant.CHANCELIER_CARD_DESTINATION_ENUM.HAND:
		await move_to_hand(cards[0])
	else:
		await move_to_deck(cards[0])
	
	if action.chancelier_card_destinations.second == Constant.CHANCELIER_CARD_DESTINATION_ENUM.HAND:
		await move_to_hand(cards[1])
	else:
		await move_to_deck(cards[1])
	
	if action.chancelier_card_destinations.third == Constant.CHANCELIER_CARD_DESTINATION_ENUM.HAND:
		await move_to_hand(cards[2])
	else:
		await move_to_deck(cards[2])
	validate()


func move_to_deck(card:Card) -> void:
	var tween := create_tween()
	var deck:Deck =  get_tree().get_nodes_in_group("Deck")[0]
	tween.tween_property(card, "global_position", deck.global_position, 0.5)
	await tween.finished
	deck.take_back(card)
	


func move_to_hand(card:Card) -> void:
	await player_ref.draw_card(card)
