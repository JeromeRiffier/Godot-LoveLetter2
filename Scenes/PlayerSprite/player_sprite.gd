class_name PlayerSprite extends Sprite2D

@onready var death_crosse: Sprite2D = $DeathCrosse
@onready var shield: Sprite2D = $Shield
@onready var death: Sprite2D = $Death

@export var is_dead:bool = false:
	set(value):
		is_dead = value
		death_crosse.visible = value
		death.visible = value

@export var is_protected:bool = false:
	set(value):
		is_protected = value
		shield.visible = value
