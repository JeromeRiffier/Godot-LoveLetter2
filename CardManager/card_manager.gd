class_name CardManager extends Node2D

const COLLISION_MASK_CARD:int = 1
const COLLISION_MASK_CARD_SLOT:int = 2

var card_being_dragged: Card = null:
	set(value):
		if value:
			value.z_index += 1
		elif card_being_dragged:
			card_being_dragged.z_index -= 1
		card_being_dragged = value
			
var is_hovering_on_card:bool = false
var screen_size:Vector2
var mouse_offset:Vector2 = Vector2.ZERO

@export var player_hand_reference:PlayerHand
@export var input_manager_reference:InputManager

func _ready() -> void:
	screen_size = get_viewport_rect().size

func _process(_delta: float) -> void:
	if card_being_dragged:
		var mouse_pos = get_global_mouse_position()
		card_being_dragged.position = Vector2(clamp(mouse_pos.x-mouse_offset.x, 0, screen_size.x), clamp(mouse_pos.y-mouse_offset.y, 0, screen_size.y))

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			var result := input_manager_reference.raycast_event()
			var card := result.card
			if card:
				mouse_offset = get_global_mouse_position() - card.global_position
				start_drag(card)
		elif card_being_dragged:
			finish_drag()

#region signals & events
func connect_card_signals(card:Card) -> void:
	card.hovered.connect(on_hovered_hover_card)
	card.hovered_off.connect(on_hovered_off_card)

func on_hovered_hover_card(card:Card) -> void:
	if not is_hovering_on_card:
		is_hovering_on_card = true
		highlight_card(card, true)
func on_hovered_off_card(card:Card) -> void:
	highlight_card(card, false)
	var new_card_hovered =  input_manager_reference.raycast_check_for_card()
	if new_card_hovered:
		highlight_card(new_card_hovered, true)
	else :
		is_hovering_on_card = false
#endregion

func highlight_card(card:Card, hovered:bool) -> void:
	if hovered:
		card.scale = Vector2(1.1, 1.1)
	else: 
		card.scale = Vector2.ONE

func start_drag(card:Card) -> void:
	card_being_dragged = card
	card_being_dragged.scale = Vector2(1.05, 1.05)
	


func finish_drag() -> void:
	card_being_dragged.scale = Vector2(1.1, 1.1)
	var card_slot_found = input_manager_reference.raycast_check_for_card_slot()
	if card_slot_found and not card_slot_found.card_already_in_slot:
		player_hand_reference.remove_card_from_hand(card_being_dragged)
		card_being_dragged.position = card_slot_found.position
		card_being_dragged.get_node("Area2D/CollisionShape2D").disabled = true
		card_slot_found.card_already_in_slot = true
	else:
		player_hand_reference.add_card_to_hand(card_being_dragged)
	card_being_dragged = null
	
