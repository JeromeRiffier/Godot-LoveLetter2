class_name Card extends Node2D

var infos:CardInfos

@onready var card_image: Sprite2D = $CardImage

const CARD_BACK = preload("uid://d1gubj60q410c")

signal hovered(card:Card)
signal hovered_off(card:Card)

var position_in_hand:Vector2
var is_dragged:bool=false
var front:bool = true

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
		var mouse_global_pos = get_global_mouse_position()
		self.global_position = Vector2(clamp(mouse_global_pos.x, 0, get_tree().get_root().size.x), clamp(mouse_global_pos.y, 0, get_tree().get_root().size.y))

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
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "rotation_degrees", 30, 0.3)
	tween.tween_property(self, "rotation_degrees", -30, 0.3)
	tween.tween_property(self, "rotation_degrees", 0, 0.3)
	await tween.finished
