class_name Card extends Node2D

signal hovered(card:Card)
signal hovered_off(card:Card)

var position_in_hand:Vector2

func _ready() -> void:
	var parent := get_parent()
	if parent and parent.has_method('connect_card_signals'):
		get_parent().connect_card_signals(self)

func _on_area_2d_mouse_entered() -> void:
	hovered.emit(self)


func _on_area_2d_mouse_exited() -> void:
	hovered_off.emit(self)
