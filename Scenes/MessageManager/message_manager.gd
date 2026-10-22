class_name MessageManager extends CenterContainer

static var instance:MessageManager
@onready var label: Label = $Label

func _enter_tree() -> void:
	if instance != null and instance != self:
		queue_free()  # un doublon existe déjà
		return
	instance = self

func _exit_tree() -> void:
	if instance == self:
		instance = null


func _ready() -> void:
	label.text = ""

func display_text(message:String, duration:float = 1.5) -> void:
	label.add_theme_color_override("font_color", Color.TRANSPARENT)
	label.text = message
	label.size = get_viewport_rect().size
	label.global_position = Vector2.ZERO
	var tween := create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_EXPO)
	tween.tween_property(label, "theme_override_colors/font_color", Color.WHITE, duration)
	await tween.finished
	label.add_theme_color_override("font_color", Color.TRANSPARENT)
