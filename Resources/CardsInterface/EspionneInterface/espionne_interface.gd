class_name EspionneInterface extends CardInterface


func enter() -> void:
	super() # Execute parenter enter func
	if player_ref:
		player_ref.as_played_spy = true
	validate()
