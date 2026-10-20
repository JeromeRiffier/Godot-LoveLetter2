class_name PrincesseInterface extends CardInterface


func enter() -> void:
	super() # Execute parenter enter func
	player_ref.kill()
	player_action.card_type_played_index = Constant.CardTypes.find(Constant.PRINCESS)
	validate()
