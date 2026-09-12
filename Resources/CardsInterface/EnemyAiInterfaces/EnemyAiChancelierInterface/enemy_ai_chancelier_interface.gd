class_name EnemyAIChancelierInterface extends ChancelierInterface



func enter() -> void:
	await super() # Execute parenter enter func
	
	var card_for_hand:Card = cards.pick_random()
	cards.erase(card_for_hand)
	await move_to_hand(card_for_hand)
	
	while not cards.is_empty():
		var card_for_deck:Card = cards.pick_random()
		cards.erase(card_for_deck)
		await move_to_deck(card_for_deck)
	
	validate()


func move_to_deck(card:Card) -> void:
	var tween = create_tween()
	var deck:Deck =  get_tree().get_nodes_in_group("Deck")[0]
	tween.tween_property(card, "global_position", deck.global_position, 0.5)
	await tween.finished
	deck.take_back(card)
	


func move_to_hand(card:Card) -> void:
	await player_ref.draw_card(card)
