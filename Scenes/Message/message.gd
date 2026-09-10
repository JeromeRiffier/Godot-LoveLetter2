class_name Message extends Label

func _ready() -> void:
	self.text = ""

func display_text(message:String, duration:float = 1.5) -> void:
	self.add_theme_color_override("font_color", Color.TRANSPARENT)
	self.text = message
	self.size = get_tree().root.size
	self.global_position = Vector2.ZERO
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_EXPO)
	tween.tween_property(self, "theme_override_colors/font_color", Color.WHITE, duration)
	await tween.finished
	self.add_theme_color_override("font_color", Color.TRANSPARENT)
