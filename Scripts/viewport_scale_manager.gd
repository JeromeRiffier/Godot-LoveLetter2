class_name ViewportScaleManager extends Control


## false = tout est visible avec des bandes noires (letterbox)
## true  = l'écran est rempli et le surplus est rogné
@export var cover := false
@export var viewport: SubViewport
@onready var center_container: CenterContainer = $CenterContainer
func _ready() -> void:
	viewport.size = Constant.MIN_WINDOW_SIZE
	#container.custom_minimum_size  = Constant.MIN_WINDOW_SIZE
	center_container.pivot_offset = Constant.MIN_WINDOW_SIZE / 2.0
	resized.connect(_update_scale)
	queue_redraw()
	_update_scale()

func _update_scale() -> void:
	#if size.x >= Constant.MIN_WINDOW_SIZE.x and size.y >= Constant.MIN_WINDOW_SIZE.y:
		#container.scale = Vector2.ONE
		#return
	var ratio_x := size.x / Constant.MIN_WINDOW_SIZE.x
	var ratio_y := size.y / Constant.MIN_WINDOW_SIZE.y
	var min_ratio := minf(ratio_x, ratio_y)
	if min_ratio > 1:
		center_container.scale = Vector2.ONE
		viewport.size = size
	else:
		viewport.size = Constant.MIN_WINDOW_SIZE
		center_container.scale =  Vector2(min_ratio, min_ratio)
	
