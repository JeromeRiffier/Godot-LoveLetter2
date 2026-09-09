## Base class for card interfaces when played, should be called by enter() and finish with validate()
## the use function will be overriden by the real user of this class
class_name CardInterface extends Node2D

@export var player_ref:Player


signal card_played


func enter() -> void:
	print("OUECH")
	if player_ref:
		player_ref.is_protected = false
	use()

func use() -> void:
	pass

func validate() -> void:
	card_played.emit()
