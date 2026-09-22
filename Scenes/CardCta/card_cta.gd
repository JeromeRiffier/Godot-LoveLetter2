class_name CardCta extends Sprite2D

@onready var pointable: Pointable = $Pointable

signal selected(emitter:CardCtaDeck, card:Card)


var selectable:bool = false:
	set(value):
		selectable = value
		pointable.is_pointable = selectable


func _on_pointable_is__no_more_pointed_at() -> void:
	if not selectable:
		return
	self.offset.x = 0


func _on_pointable_is_pointed_at() -> void:
	if not selectable:
		return
	self.offset.x = 5


func _on_pointable_is_selected() -> void:
	selected.emit(self, get_parent())
	selectable = false
