class_name PrinceInterface extends CardInterface


@onready var message: Message = $Message

var enemies:Array[Player]

func enter() -> void:
	super() # Execute parenter enter func
	enemies = player_ref.get_vulnerable_enemies()
	
