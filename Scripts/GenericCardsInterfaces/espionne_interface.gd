class_name EspionneInterface extends CardInterface


func enter() -> void:
	super() # Execute parenter enter func
	if player_ref:
		player_ref.as_played_spy = true
	player_action.card_type_played_index = Constant.CardTypes.find(Constant.ESPIONNE)
	validate()
