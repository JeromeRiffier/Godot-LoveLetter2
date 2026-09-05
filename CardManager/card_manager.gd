class_name CardManager extends Node2D

const COLLISION_MASK_CARD:int = 1

var card_being_dragged: Card = null
var is_hovering_on_card:bool = false
var screen_size:Vector2
var mouse_offset:Vector2 = Vector2.ZERO


func _ready() -> void:
	screen_size = get_viewport_rect().size

func _process(delta: float) -> void:
	if card_being_dragged:
		var mouse_pos = get_global_mouse_position()
		card_being_dragged.position = Vector2(clamp(mouse_pos.x-mouse_offset.x, 0, screen_size.x), clamp(mouse_pos.y-mouse_offset.y, 0, screen_size.y))

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			var card = raycast_check_for_card()
			if card:
				mouse_offset = get_global_mouse_position() - card.global_position
				card_being_dragged = card
		else :
			card_being_dragged = null


func connect_card_signals(card:Card) -> void:
	card.hovered.connect(on_hovered_hover_card)
	card.hovered_off.connect(on_hovered_off_card)

func on_hovered_hover_card(card:Card) -> void:
	if not is_hovering_on_card:
		is_hovering_on_card = true
		highlight_card(card, true)
func on_hovered_off_card(card:Card) -> void:
	highlight_card(card, false)
	var new_card_hovered =  raycast_check_for_card()
	if new_card_hovered:
		highlight_card(new_card_hovered, true)
	else :
		is_hovering_on_card = false
	

### 
##Check if the mouse position collide with a card
## return the first card detected
### 
func raycast_check_for_card() -> Card:
	var space_state := get_world_2d().direct_space_state
	var parameters := PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = COLLISION_MASK_CARD
	var results := space_state.intersect_point(parameters)
	var cards :Array[Card]
	cards.assign(results.map(
			func (element:Dictionary) -> Card: return element.collider.get_parent()
		).filter(
			func (element) -> bool: return element is Card
		)
	)
	if not cards:
		return null
	print(cards)
	var highest_card:Card = get_card_with_highest_z_index(cards)
	return highest_card

func get_card_with_highest_z_index(cards:Array[Card]) -> Card:
	if cards.is_empty():
		return null
	var highest_card = cards[0]
	for card:Card in cards:
		if card.z_index > highest_card.z_index:
			highest_card = card
	return highest_card

func highlight_card(card:Card, hovered:bool) -> void:
	if hovered:
		card.scale = Vector2(1.1, 1.1)
	else: 
		card.scale = Vector2.ONE
