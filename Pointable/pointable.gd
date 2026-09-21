class_name Pointable extends Node2D


signal is_pointed_at
signal is__no_more_pointed_at
signal is_selected

var is_pointable:bool = true

func point_at() -> void:
	is_pointed_at.emit()
