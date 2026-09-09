class_name EspionneInterface extends CardInterface


func use() -> void:
	if player_ref:
		player_ref.as_played_spy = true
