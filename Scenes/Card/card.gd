class_name Card extends Node2D

var infos:CardInfos

@onready var card_image: Sprite2D = $CardImage
@onready var shadow: Sprite2D = $CardImage/Shadow
@onready var pointable: Pointable = $Pointable
@onready var card_cta_jouer: Sprite2D = $CardCtaJouer
@onready var card_cta_deck: CardCtaDeck = $CardCtaDeck
@onready var card_cta_main: CardCtaMain = $CardCtaMain

const CARD_BACK :CompressedTexture2D = preload("uid://d1gubj60q410c")
const MAX_SHADOW_OFFSET :int = 15
const CURVE_STRENGTH := 9.0
const CTA_VERTICAL_OFFSET := -22
const CTA_HORIZONTAL_OFFSET := -50

signal hovered(emitter:Card)
signal hovered_off(emitter:Card)
signal selected(emitter:Card)
signal starting_drag(emitter:Card)
signal stopping_drag(emitter:Card)

var position_in_hand:Vector2
var _starting_z_index : int
@export var is_dragged:bool=false
var selectable:bool = false:
	set(value):
		selectable = value
		pointable.is_pointable = selectable
		if not selectable:
			hide_all_cta()
var front:bool = true
var used:bool = false

func set_infos(value:CardInfos) -> void:
	infos = value
	if front:
		card_image.texture = value.texture
	else: 
		card_image.texture = CARD_BACK

func _ready() -> void:
	place_card_buttons()
	var parent := get_parent()
	if parent and parent.has_method('connect_card_signals'):
		get_parent().connect_card_signals(self)


func _process(_delta: float) -> void:
	if is_dragged:
		shadow.offset = get_shadow_offset()


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

func place_card_buttons() -> void:
	card_cta_jouer.offset.y = CTA_VERTICAL_OFFSET
	card_cta_deck.offset.x = CTA_HORIZONTAL_OFFSET
	card_cta_main.offset.x = CTA_HORIZONTAL_OFFSET

#region shadow
func get_shadow_offset() -> Vector2:
	var screen_size := Vector2(get_tree().get_root().size)
	var screen_center := screen_size / 2.0

	var percent := (screen_center - global_position) / screen_center

	return Vector2(
		_shape(percent.x)* MAX_SHADOW_OFFSET,
		14.0
	) 

func _shape(t: float) -> float:
	var a := clampf(absf(t), 0.0, 1.0)
	var shaped := log(1.0 + CURVE_STRENGTH * a) / log(1.0 + CURVE_STRENGTH)
	return signf(t) * shaped
#endregion

#region events
func _on_area_2d_mouse_entered() -> void:
	hovered.emit(self)


func _on_area_2d_mouse_exited() -> void:
	hovered_off.emit(self)


func _on_pointable_is_pointed_at() -> void:
	if selectable:
		show_cta_jouer()


func _on_pointable_is__no_more_pointed_at() -> void:
	hide_cta_jouer()


func _on_pointable_is_selected() -> void:
	hide_cta_jouer()
	selected.emit(self)
#endregion

#region button_animation
func show_cta_jouer() -> void:
		card_cta_jouer.offset.y = 0.0

func show_cta_deck() -> void:
	card_cta_deck.offset.x = 0.0

func show_cta_main() -> void:
	card_cta_main.offset.x = 0.0

func hide_all_cta() -> void:
	hide_cta_jouer()
	hide_cta_deck()
	hide_cta_main()
	
func hide_cta_jouer() -> void:
	card_cta_jouer.offset.y = CTA_VERTICAL_OFFSET

func hide_cta_deck() -> void:
	card_cta_deck.offset.x = CTA_HORIZONTAL_OFFSET

func hide_cta_main() -> void:
	card_cta_main.offset.x = CTA_HORIZONTAL_OFFSET
#endregion


func set_draggable(draggable:bool) -> void:
	pointable.is_draggable = draggable

func _on_pointable_started_behing_dragged() -> void:
	is_dragged = true
	_starting_z_index = z_index
	z_index = 100
	position_in_hand = global_position
	if card_image && shadow:
		card_image.scale = Vector2(0.9,0.9)
		shadow.scale = Vector2(1.1,1.1)
	starting_drag.emit(self)

func _on_pointable_stopped_behing_dragged() -> void:
	is_dragged = false
	z_index = _starting_z_index
	if card_image and shadow:
		card_image.scale = Vector2.ONE
		shadow.scale = Vector2.ONE
		shadow.offset = Vector2.ZERO
	stopping_drag.emit(self)
	
