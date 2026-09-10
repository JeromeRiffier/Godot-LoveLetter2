## Base class for card interfaces when played, should be called by enter() and finish with validate()
## the use function will be overriden by the real user of this class
class_name CardInterface extends Node2D

@export var player_ref:RealPlayer


signal card_played


func enter() -> void:
	if player_ref:
		player_ref.is_protected = false


func validate() -> void:
	await  get_tree().create_timer(0.1).timeout
	card_played.emit()
