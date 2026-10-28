class_name ViewportScaleManager extends Control

@onready var viewport_container: SubViewportContainer = $SubViewportContainer


func _ready() -> void:
	resized.connect(_update_scale)
	_update_scale()

## Force the viewport container to scale down the viewport if it become smaller than Constant.MIN_WINDOW_SIZE
## While retaining it's ratio
func _update_scale() -> void:
	var full_size := size
	var base := Vector2(Constant.MIN_WINDOW_SIZE)
	
	var scale_factor := minf(1.0, minf(full_size.x / base.x, full_size.y / base.y))
	var new_size := size * (1/scale_factor)
	
	## When initializing the control node godot do some strange things and size can be undefined
	## If we try to set a size with nan it result in an error so this verification is needed
	if  is_nan(new_size.x) and is_nan(new_size.y):
		return
	
	## Using set_deferred because godot is not happy if we set a size for a control node in the ready function
	## It would be overriden by some other control node magics
	viewport_container.set_deferred("size", new_size)
	viewport_container.set_deferred("scale", Vector2(scale_factor, scale_factor))
