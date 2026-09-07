class_name InputManager extends Node2D

const CARD_MASK = 1
const CARD_SLOT_MASK = 2
const DECK_MASK = 4
#
#
#func _input(event: InputEvent) -> void:
	#if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		#if event.is_pressed():
			#return raycast_event()
#
func raycast_event() -> RaycastResult:
	return RaycastResult.new(
			raycast_check_for_card(),
			raycast_check_for_card_slot(),
			raycast_check_for_deck(),
		)






### 
## Check if the mouse position collide with a card
## return the first card detected
### 
func raycast_check_for_card() -> Card:
	var colision_result:Array[Dictionary] = ray_cast_at_cursor(CARD_MASK)
	var cards :Array[Card]
	cards.assign(colision_result.map(
			func (element:Dictionary) -> Card: return element.collider.get_parent()
		).filter(
			func (element) -> bool: return element is Card
		)
	)
	if not cards:
		return null
	var highest_card:Card = get_card_with_highest_z_index(cards)
	return highest_card

### 
## Check if the mouse position collide with a card slot
## return the first card detected
### 
func raycast_check_for_card_slot() -> CardSlot:
	var colision_result:Array[Dictionary] = ray_cast_at_cursor(CARD_SLOT_MASK)
	var card_slots :Array[CardSlot]
	card_slots.assign(colision_result.map(
			func (element:Dictionary) -> CardSlot: return element.collider.get_parent()
		).filter(
			func (element) -> bool: return element is CardSlot
		)
	)
	if not card_slots:
		return null
	return card_slots[0]

### 
## Check if the mouse position collide with a deck
## return the first card detected
### 
func raycast_check_for_deck() -> Deck:
	var colision_result:Array[Dictionary] = ray_cast_at_cursor(DECK_MASK)
	var decks :Array[Deck]
	decks.assign(colision_result.map(
			func (element:Dictionary) -> Deck: return element.collider.get_parent()
		).filter(
			func (element) -> bool: return element is Deck
		)
	)
	if not decks:
		return null
	return decks[0]

#region Helpers
## Check object collision with mouse pointer for a given colisionMask
func ray_cast_at_cursor(collision_mask:int) -> Array[Dictionary]:
	var space_state := get_world_2d().direct_space_state
	var parameters := PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = collision_mask
	var results := space_state.intersect_point(parameters)
	return results


func get_card_with_highest_z_index(cards:Array[Card]) -> Card:
	if cards.is_empty():
		return null
	var highest_card = cards[0]
	for card:Card in cards:
		if card.z_index > highest_card.z_index:
			highest_card = card
	return highest_card
#endregion
