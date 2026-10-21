## The main class for the real player on this device
## Always call interfaces when playing and wait for the player to make it's moves
class_name LocalPlayer extends Player



#region CardsInterfaces
@onready var princesse_interface: LocalPlayerPrincesseInterface = $CardsInterfaces/PrincesseInterface
@onready var comtesse_interface: LocalPlayerComtesseInterface = $CardsInterfaces/ComtesseInterface
@onready var roi_interface: LocalPlayerRoiInterface = $CardsInterfaces/RoiInterface
@onready var chancelier_interface: LocalPlayerChancelierInterface = $CardsInterfaces/ChancelierInterface
@onready var prince_interface: LocalPlayerPrinceInterface = $CardsInterfaces/PrinceInterface
@onready var baron_interface: LocalPlayerBaronInterface = $CardsInterfaces/BaronInterface
@onready var servante_interface: LocalPlayerServanteInterface = $CardsInterfaces/ServanteInterface
@onready var pretre_interface: LocalPlayerPretreInterface = $CardsInterfaces/PretreInterface
@onready var garde_interface: LocalPlayerGardeInterface = $CardsInterfaces/GardeInterface
@onready var espionne_interface: LocalPlayerEspionneInterface = $CardsInterfaces/EspionneInterface
#endregion

@warning_ignore("unused_signal")
signal need_to_select_enemy(value:bool) 

func set_label() -> void:
	var self_peer_id := multiplayer.get_unique_id()
	$NameLabel.text = "%s - %s" % [name, self_peer_id]

func play_card(card:Card) -> void:
	print("%s play %s" % [name, card.infos])
	var player_action := PlayerAction.new()
	match card.infos:
		Constant.PRINCESS:
			princesse_interface.enter()
			player_action = await princesse_interface.card_played
		Constant.COMTESSE:
			comtesse_interface.enter()
			player_action = await comtesse_interface.card_played
		Constant.ROI:
			roi_interface.enter()
			player_action = await roi_interface.card_played
		Constant.CHANCELIER:
			chancelier_interface.enter()
			player_action = await chancelier_interface.card_played
		Constant.PRINCE:
			prince_interface.enter()
			player_action = await prince_interface.card_played
		Constant.BARON:
			baron_interface.enter()
			player_action = await baron_interface.card_played
		Constant.SERVANTE:
			servante_interface.enter()
			player_action = await servante_interface.card_played
		Constant.PRÊTRE:
			pretre_interface.enter()
			player_action = await pretre_interface.card_played
		Constant.GARDE:
			garde_interface.enter()
			player_action = await garde_interface.card_played
		Constant.ESPIONNE:
			espionne_interface.enter()
			player_action = await espionne_interface.card_played
	card.used = true
	player_action.player_peer_id = multiplayer.get_unique_id()
	player_action.player_index = GameManager.instance.players.find(self)
	has_played.emit(self, card, player_action)

func start_playing() -> void:
	enable_card_selection()

func stop_playing() -> void:
	#disable_card_selection()
	pass

func draw_card(card:Card) -> void:
	card.show_card()
	super(card)
	card.set_draggable(true)
	if not card.stopping_drag.is_connected(on_card_stopping_drag):
		card.stopping_drag.connect(on_card_stopping_drag)


func on_card_stopping_drag(card:Card) -> void:
	var card_slot_found := raycast_check_for_card_slot()
	if card_slot_found and card_slot_found == card_slot:
		use_card(card)
	else:
		hand.reposition_card(card)

func enable_card_selection() -> void:
	for card in hand.cards:
		card.selectable = true
		card.selected.connect(use_card)
	var pointableManager:PointableManager = get_tree().get_first_node_in_group("PointableManager")
	if pointableManager:
		pointableManager.pre_point_to_pointable()

func disable_card_selection() -> void:
	for card in hand.cards:
		card.selectable = false
		card.selected.disconnect(use_card)
func use_card(card:Card) -> void:
	disable_card_selection()
	
	if card.stopping_drag.is_connected(on_card_stopping_drag):
		card.stopping_drag.disconnect(on_card_stopping_drag)
	if is_card_playable(card):
		hand.remove_card_from_hand(card)
		await card_slot.receive_card(card)
		play_card(card)
	else: 
		await card.animated_card_forbiden()
		hand.reposition_card(card)
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
			func (element:Variant) -> bool: return element is Card
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
	var highest_card := cards[0]
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
			func (element:Variant) -> bool: return element is CardSlot
		)
	)
	if not card_slots:
		return null
	return card_slots[0]
#endregion
