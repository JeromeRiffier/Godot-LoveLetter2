@tool
class_name ValuePanel extends PanelContainer

@export var title: String = "":
	set(val):
		title = val
		set_nodes_values()
@export_multiline() var value: String = "":
	set(val):
		value = val
		set_nodes_values()

enum DirectionEnum {HORIZONTAL, VERTICAL}
@export var direction:DirectionEnum = DirectionEnum.VERTICAL:
	set(val):
		direction = val
		set_nodes_values()
	
		

@onready var title_node: Label = $BoxContainer/Title
@onready var value_node: RichTextLabel = $BoxContainer/MarginContainer/PanelContainer/Value
@onready var box_container: BoxContainer = $BoxContainer


func _ready() -> void:
	set_nodes_values()

func set_nodes_values() -> void:
	if not title_node or not value_node or not box_container:
		return
	title_node.text = title
	value_node.text = value
	match direction:
		DirectionEnum.VERTICAL:
			box_container.vertical = true
		DirectionEnum.HORIZONTAL:
			box_container.vertical = false
