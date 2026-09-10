class_name PlayerSprite extends Sprite2D

@onready var death_crosse: Sprite2D = $DeathCrosse
@onready var shield: Sprite2D = $Shield
@onready var death: Sprite2D = $Death
@onready var spy: Sprite2D = $Spy

@export var is_dead:bool = false:
	set(value):
		is_dead = value
		death_crosse.visible = value
		death.visible = value

@export var is_protected:bool = false:
	set(value):
		is_protected = value
		shield.visible = value

@export var is_spy:bool = false:
	set(value):
		print("set is_spy ", value)
		is_spy = value
		spy.visible = value

func _ready() -> void:
	death_crosse.visible = false
	shield.visible = false
	death.visible = false
	spy.visible = false
