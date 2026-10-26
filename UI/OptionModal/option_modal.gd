class_name OptionModal extends CanvasLayer

@onready var main_option_modal: PanelContainer = $CenterContainer/MainOptionModal
@onready var network_option_modal: TabContainer = $CenterContainer/NetworkOptionModal
@onready var center_container: CenterContainer = $CenterContainer

func _ready() -> void:
	if get_parent() == get_tree().root:
		enter()
	else:
		self.visible = false

func enter() -> void:
	center_container.offset_top = get_viewport().get_visible_rect().size.y
	_switch_to_main_modal()
	self.visible = true
	var tween := create_tween()
	tween.tween_property(center_container, "offset_top", 0.0, 0.3)
	
func exit() -> void:
	var tween := create_tween()
	tween.tween_property(center_container, "offset_top", get_viewport().get_visible_rect().size.y, 0.3)
	await tween.finished
	self.visible = false

func _switch_to_main_modal() -> void:
	main_option_modal.visible = true
	network_option_modal.visible = false

func _switch_to_network_modal() -> void:
	main_option_modal.visible = false
	network_option_modal.visible = true


func _on_close_button_pressed() -> void:
	exit()


func _on_open_network_button_pressed() -> void:
	_switch_to_network_modal()


func _on_network_option_modal_close() -> void:
	_switch_to_main_modal()
