class_name Card extends Node2D

var infos:CardInfos

@onready var card_image: Sprite2D = $CardImage
@onready var shadow: Sprite2D = $CardImage/Shadow

const CARD_BACK :CompressedTexture2D = preload("uid://d1gubj60q410c")


signal hovered(card:Card)
signal hovered_off(card:Card)

var position_in_hand:Vector2
var _starting_z_index : int
@export var is_dragged:bool=false:
	set(value):
		is_dragged = value
		if value:
			_starting_z_index = z_index
			z_index = 100
			if card_image && shadow:
				card_image.scale = Vector2(0.9,0.9)
				shadow.scale = Vector2(1.1,1.1)
				
		else:
			z_index = _starting_z_index
			if card_image and shadow:
				card_image.scale = Vector2.ONE
				shadow.scale = Vector2.ONE
				shadow.offset = Vector2.ZERO
				
			
var front:bool = true
var used:bool = false

func set_infos(value:CardInfos) -> void:
	infos = value
	if front:
		card_image.texture = value.texture
	else: 
		card_image.texture = CARD_BACK

func _ready() -> void:
	var parent := get_parent()
	if parent and parent.has_method('connect_card_signals'):
		get_parent().connect_card_signals(self)

func _process(_delta: float) -> void:
	if is_dragged:
		var mouse_global_pos := get_global_mouse_position()
		self.global_position = Vector2(clamp(mouse_global_pos.x, 0, get_tree().get_root().size.x), clamp(mouse_global_pos.y, 0, get_tree().get_root().size.y))
		shadow.offset = get_shadow_offset()
func _on_area_2d_mouse_entered() -> void:
	hovered.emit(self)

func _on_area_2d_mouse_exited() -> void:
	hovered_off.emit(self)

func hide_card() -> void:
	front = false
	card_image.texture = CARD_BACK
func show_card() -> void:
	front = true
	card_image.texture = infos.texture

func animated_card_forbiden() -> void:
	var tween := create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "rotation_degrees", 30, 0.3)
	tween.tween_property(self, "rotation_degrees", -30, 0.3)
	tween.tween_property(self, "rotation_degrees", 0, 0.3)
	await tween.finished

const MAX_SHADOW_OFFSET :int = 15
const CURVE_STRENGTH := 9.0
func get_shadow_offset() -> Vector2:
	var screen_size := Vector2(get_tree().get_root().size)
	var screen_center := screen_size / 2.0

	var percent := (screen_center - global_position) / screen_center

	return Vector2(
		_shape(percent.x),
		_shape(percent.y)
	) * MAX_SHADOW_OFFSET


func _shape(t: float) -> float:
	var a := clampf(absf(t), 0.0, 1.0)
	var shaped := log(1.0 + CURVE_STRENGTH * a) / log(1.0 + CURVE_STRENGTH)
	return signf(t) * shaped
