class_name ComtesseInterface extends CardInterface


func enter() -> void:
	super() # Execute parenter enter func
	player_action.card_type_played_index = Constant.CardTypes.find(Constant.COMTESSE)
	validate()
