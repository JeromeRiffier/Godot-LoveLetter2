class_name Pointable extends Node2D


signal is_pointed_at
signal is__no_more_pointed_at
signal is_selected

@export var is_pointable:bool = false

func point_at() -> void:
	is_pointed_at.emit()

func unpoint_at() -> void:
	is__no_more_pointed_at.emit()

func validate() -> void:
	is_selected.emit()
