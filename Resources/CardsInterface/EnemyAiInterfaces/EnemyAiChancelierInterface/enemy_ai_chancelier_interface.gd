class_name EnemyAIChancelierInterface extends ChancelierInterface



func enter() -> void:
	super() # Execute parenter enter func
	
	var first_card:Card = cards.pick_random()
	cards.erase(first_card)
	await move_to_deck(first_card)
	
	var second_card:Card = cards.pick_random()
	cards.erase(second_card)
	await move_to_deck(second_card)
	
	var third_card:Card = cards[0]
	cards.erase(third_card)
	await move_to_hand(second_card)
		
	validate()

func move_to_deck(card:Card) -> void:
	var tween = create_tween()
	var deck:Deck =  get_tree().get_nodes_in_group("Deck")[0]
	tween.tween_property(card, "global_position", deck, 0.3)
	deck.take_back(card)
	await tween.finished


func move_to_hand(card:Card) -> void:
	player_ref.draw_card(card)
