class_name PretreInterface extends CardInterface

var enemies:Array[Player]

func enter() -> void:
	super() # Execute parenter enter func
	enemies = player_ref.get_vulnerable_enemies()
	player_action.card_type_played_index = Constant.CardTypes.find(Constant.PRÊTRE)
