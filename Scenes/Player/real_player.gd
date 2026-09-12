class_name RealPlayer extends Player

var card_being_dragged:Card = null

#region CardsInterfaces
@onready var princesse_interface: PlayerPrincesseInterface = $CardsInterfaces/PrincesseInterface
@onready var comtesse_interface: PlayerComtesseInterface = $CardsInterfaces/ComtesseInterface
@onready var roi_interface: PlayerRoiInterface = $CardsInterfaces/RoiInterface
@onready var chancelier_interface: PlayerChancelierInterface = $CardsInterfaces/ChancelierInterface
@onready var prince_interface: PlayerPrinceInterface = $CardsInterfaces/PrinceInterface
@onready var baron_interface: PlayerBaronInterface = $CardsInterfaces/BaronInterface
@onready var servante_interface: PlayerServanteInterface = $CardsInterfaces/ServanteInterface
@onready var pretre_interface: PlayerPretreInterface = $CardsInterfaces/PretreInterface
@onready var garde_interface: PlayerGardeInterface = $CardsInterfaces/GardeInterface
@onready var espionne_interface: PlayerEspionneInterface = $CardsInterfaces/EspionneInterface
#endregion

signal need_to_select_enemy(value:bool)

func play_card(card:Card) -> void:
	print("%s play %s" % [name, card.infos])
	match card.infos:
		Constant.PRINCESS:
			princesse_interface.enter()
			await princesse_interface.card_played
		Constant.COMTESSE:
			comtesse_interface.enter()
			await comtesse_interface.card_played
		Constant.ROI:
			roi_interface.enter()
			await roi_interface.card_played
		Constant.CHANCELIER:
			chancelier_interface.enter()
			await chancelier_interface.card_played
		Constant.PRINCE:
			prince_interface.enter()
			await prince_interface.card_played
		Constant.BARON:
			baron_interface.enter()
			await baron_interface.card_played
		Constant.SERVANTE:
			servante_interface.enter()
			await servante_interface.card_played
		Constant.PRÊTRE:
			pretre_interface.enter()
			await pretre_interface.card_played
		Constant.GARDE:
			garde_interface.enter()
			await garde_interface.card_played
		Constant.ESPIONNE:
			espionne_interface.enter()
			await espionne_interface.card_played
	has_played.emit(self, card)


func _unhandled_input(event: InputEvent) -> void:
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

func draw_card(card:Card) -> void:
	card.show_card()
	super(card)

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
			play_card(card_being_dragged)
		else: 
			await card_being_dragged.animated_card_forbiden()
			hand.reposition_card(card_being_dragged)
	else:
		hand.reposition_card(card_being_dragged)
	card_being_dragged = null


#region input
### 
## Check if the mouse position collide with a card
## return the first card detected
### 
func raycast_check_for_card() -> Card:
	var colision_result:Array[Dictionary] = ray_cast_at_cursor(Constant.CARD_MASK)
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
	var colision_result:Array[Dictionary] = ray_cast_at_cursor(Constant.CARD_SLOT_MASK)
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
