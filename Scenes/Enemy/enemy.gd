class_name Enemy extends Player

## Disable parent (Player) input management
func _input(_event: InputEvent) -> void:
	return


func takeTurn():
	await get_tree().create_timer(0.2).timeout
	
	## TODO to be reworked
	var card_to_play:Card = hand.cards[0]
	if not is_card_playable(card_to_play):
		card_to_play = hand.cards[1]
	## END TODO
	
	await animate_card_to_slot(card_to_play)
	hand.remove_card_from_hand(card_to_play)
	card_slot.receive_card(card_to_play)

	card_to_play.process_mode = Node.PROCESS_MODE_DISABLED ## I suppose disabling the full node will work as fine as disabling the colisionShape 
	has_played.emit()

func animate_card_to_slot(card:Card) -> void:
	var tween = create_tween()
	tween.tween_property(card, "global_position", card_slot.global_position, 0.2 )
	await tween.finished
