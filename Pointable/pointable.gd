class_name Pointable extends Area2D


signal is_pointed_at
signal is__no_more_pointed_at
signal is_selected
signal started_behing_dragged
signal stopped_behing_dragged

@export var is_pointable:bool = false
@export var is_draggable:bool = false

func point_at() -> void:
	is_pointed_at.emit()

func unpoint_at() -> void:
	is__no_more_pointed_at.emit()

func validate() -> void:
	is_selected.emit()

func start_behing_dragged() -> void:
	started_behing_dragged.emit()

func stop_behing_dragged() -> void:
	stopped_behing_dragged.emit()
