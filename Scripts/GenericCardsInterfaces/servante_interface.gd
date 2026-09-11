class_name ServanteInterface extends CardInterface


func enter() -> void:
	super() # Execute parenter enter func
	player_ref.is_protected = true
	validate()
