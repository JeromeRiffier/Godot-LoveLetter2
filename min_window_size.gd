extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	DisplayServer.window_set_min_size(Constant.MIN_WINDOW_SIZE)
	queue_free()
