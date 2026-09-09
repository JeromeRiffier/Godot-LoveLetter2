class_name Player extends Marker2D

const CARD_MASK = 1
const CARD_SLOT_MASK = 2
@onready var hand: Hand = $Hand
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var card_slot: CardSlot = $CardSlot


var card_being_dragged:Card = null
var is_playing:bool = false
var is_protected:bool = false
var is_alive:bool = false

signal has_played

#func _ready() -> void:
	### For debug only, card should be received from GameManager
	#await get_tree().create_timer(0.5).timeout
	#var card:Card = preload("uid://c7em3t5lv5vr0").instantiate()
	#add_child(card)
	#card.set_infos(Constant.ROI)
	#card.global_position = Vector2.ZERO
	#draw_card(card)
	#await get_tree().create_timer(0.5).timeout
	#
	#var card_2:Card = preload("uid://c7em3t5lv5vr0").instantiate()
	#add_child(card_2)
	#card_2.set_infos(Constant.COMTESSE)
	#card_2.global_position = Vector2.ZERO
	#draw_card(card_2)
	#await get_tree().create_timer(0.5).timeout
	#is_playing = true
	

func draw_card(card:Card) -> void:
	hand.add_card_to_hand(card)

func _input(event: InputEvent) -> void:
	if not is_playing:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			var card:Card = raycast_check_for_card()
			if hand.cards.has(card):
				start_drag(card)
		else:
			if card_being_dragged:
				finish_drag()

func start_drag(card:Card) -> void:
	card_being_dragged = card
	card.is_dragged = true

func finish_drag() -> void:
	card_being_dragged.is_dragged = false
	var card_slot_found = raycast_check_for_card_slot()
	if card_slot_found and card_slot_found == card_slot:
		if is_card_playable(card_being_dragged):
			hand.remove_card_from_hand(card_being_dragged)
			card_slot.receive_card(card_being_dragged)
			card_being_dragged.global_position = card_slot_found.global_position
			#card_being_dragged.get_node("Area2D/CollisionShape2D").disabled = true
			card_being_dragged.process_mode = Node.PROCESS_MODE_DISABLED ## I suppose disabling the full node will work as fine as disabling the colisionShape 
			has_played.emit()
		else: 
			await card_being_dragged.animated_card_forbiden()
			hand.reposition_card(card_being_dragged)
	else:
		hand.reposition_card(card_being_dragged)
	card_being_dragged = null

func is_card_playable(card:Card) -> bool:
	var is_roi_or_prince:bool = [Constant.PRINCE, Constant.ROI].has(card.infos)
	var hand_contain_comtesse:bool = hand.cards.any(func (element:Card) -> bool: return element.infos == Constant.COMTESSE)
	if is_roi_or_prince and hand_contain_comtesse:
		return false
	return true

#region input
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
#endregion
