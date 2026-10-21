## Base class for card interfaces when played, should be called by enter() and finish with validate()
## the use function will be overriden by the real user of this class
class_name CardInterface extends Node2D

@export var player_ref:Player

var is_active:bool

var player_action:PlayerAction
signal card_played(player_action:PlayerAction)

func enter() -> void:
	is_active = true
	if player_ref:
		player_ref.is_protected = false
	player_action = PlayerAction.new()


func validate() -> void:
	await  get_tree().create_timer(0.1).timeout
	is_active = false
	card_played.emit(player_action)

func pre_point_enemy() -> void:
	var pointableManager:PointableManager = get_tree().get_first_node_in_group("PointableManager")
	if pointableManager:
		pointableManager.pre_point_to_pointable()

## Record action as Discarded and validate the CardInterface
func manage_unplayable_case() -> void:
	player_action.action_discarded = true
	validate()
