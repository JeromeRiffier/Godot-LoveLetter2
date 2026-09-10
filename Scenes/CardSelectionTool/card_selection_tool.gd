class_name CardSelectionTool extends Node2D

const CARD_SCENE = preload("uid://c7em3t5lv5vr0")
const BOTTOM_MARGIN:int = 100

@onready var cards_node: Node2D = $Cards
@onready var background_color: ColorRect = $BackgroundColor


var cards:Array[Card]

var screen_center_x:float
var screen_center_y:float
var screen_bottom:int

@export var selection_active:bool = false

signal card_selected(card:CardInfos)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	## Do not forget to disable mouse filtering on any control node to not mess with inputs
	#background_color.mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_screen_values()
	get_tree().root.size_changed.connect(on_viewport_size_changed)
	for cardInfo in Constant.CardTypesWithoutGuard:
		var card_node:Card = CARD_SCENE.instantiate()
		cards_node.add_child(card_node)
		card_node.set_infos(cardInfo)
		cards.append(card_node)
	update_hand_positions()
	set_background_size()

func _unhandled_input(event: InputEvent) -> void:
	if not selection_active:
		return
	get_viewport().set_input_as_handled()
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			var space_state := get_world_2d().direct_space_state
			var parameters := PhysicsPointQueryParameters2D.new()
			parameters.position = get_global_mouse_position()
			parameters.collide_with_areas = true
			parameters.collision_mask = 1
			var colision_result := space_state.intersect_point(parameters)
			var colision_filtered = colision_result.filter(func (result:Dictionary) -> bool: return cards.has(result.collider.get_parent()) )
			if not colision_filtered.is_empty():
				var card:Card = colision_filtered[0].collider.get_parent()
				card_selected.emit(card.infos)
				disactivate()

func activate() -> void:
	selection_active = true
	set_background_properties()
	update_hand_positions()

func disactivate() -> void:
	print("disactivate card selection")
	selection_active = false
	set_background_properties()
	update_hand_positions()

#region background management
func set_background_properties() -> void:
	var tween = create_tween()
	var color:Color = "#000000dd" if selection_active else "#00000000"
	tween.tween_property(background_color, "color", color, 0.3)
	await tween.finished
func set_background_size() -> void:
	background_color.size = get_tree().root.size
	background_color.global_position = Vector2.ZERO
#endregion

#region Card positioning
func update_hand_positions() -> void:
	for i in range(cards.size()):
		var new_position =  Vector2(calculate_card_positions_x(i), calculate_card_positions_y())
		var card := cards[i]
		card.position_in_hand = new_position
		animate_card_to_position(card, new_position)

func calculate_card_positions_y() -> float:
	if selection_active:
		return  screen_center_y
	else:
		return screen_bottom + BOTTOM_MARGIN
func calculate_card_positions_x(index:int) -> float:
	var total_width := cards.size() * Constant.CARD_WIDTH
	var x_offset := screen_center_x + index * Constant.CARD_WIDTH - total_width / 2.0 + (Constant.CARD_WIDTH / 2.0)
	return x_offset
func animate_card_to_position(card:Card, new_position:Vector2) -> void:
	var tween = create_tween()
	tween.tween_property(card, "global_position", new_position, 0.1)
#endregion

#region screen responsivness
func set_screen_values() -> void:
	print("set_screen_values")
	screen_center_x = get_tree().root.size.x /2.0
	screen_center_y = get_tree().root.size.y /2.0
	screen_bottom =  get_tree().root.size.y
func on_viewport_size_changed():
	set_screen_values()
	set_background_size()
	update_hand_positions()
#endregion
