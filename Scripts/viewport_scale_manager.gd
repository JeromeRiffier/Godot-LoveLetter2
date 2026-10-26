class_name ViewportScaleManager extends Control


## false = tout est visible avec des bandes noires (letterbox)
## true  = l'écran est rempli et le surplus est rogné
@export var cover := false
## true = scale entier uniquement (pixel art net)
@export var integer_scale := false

@export var container: SubViewportContainer
@export var viewport: SubViewport

func _ready() -> void:
	viewport.size = Constant.MIN_WINDOW_SIZE
	#container.custom_minimum_size  = Constant.MIN_WINDOW_SIZE
	container.pivot_offset = Constant.MIN_WINDOW_SIZE / 2.0
	resized.connect(_update_scale)
	queue_redraw()
	_update_scale()

func _update_scale() -> void:
	var ratio := size / Constant.MIN_WINDOW_SIZE
	var s := maxf(ratio.x, ratio.y) if cover else minf(ratio.x, ratio.y)
	if integer_scale:
		s = maxf(1.0, floorf(s))
	container.scale = Vector2(s, s)
	#viewport.size_2d_override = size
