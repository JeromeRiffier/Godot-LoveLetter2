class_name EnemyAI extends Player

const ENEMY_MASK:int = 8

var selectable:bool = false
var _is_hovered:bool = false

#region CardsInterfaces
@onready var princesse_interface: EnemyAIPrincesseInterface = $CardsInterfaces/EnemyAIPrincesseInterface
@onready var baron_interface: EnemyAIBaronInterface = $CardsInterfaces/EnemyAIBaronInterface
@onready var chancelier_interface: EnemyAIChancelierInterface = $CardsInterfaces/EnemyAIChancelierInterface
@onready var comtesse_interface: EnemyAIComtesseInterface = $CardsInterfaces/EnemyAIComtesseInterface
@onready var espionne_interface: EnemyAIEspionneInterface = $CardsInterfaces/EnemyAIEspionneInterface
@onready var garde_interface: EnemyAIGardeInterface = $CardsInterfaces/EnemyAIGardeInterface
@onready var pretre_interface: EnemyAIPretreInterface = $CardsInterfaces/EnemyAIPretreInterface
@onready var prince_interface: EnemyAIPrinceInterface = $CardsInterfaces/EnemyAIPrinceInterface
@onready var roi_interface: EnemyAIRoiInterface = $CardsInterfaces/EnemyAIRoiInterface
@onready var servante_interface: EnemyAIServanteInterface = $CardsInterfaces/EnemyAIServanteInterface
#endregion 

signal enemy_selected(emiter:Player)

func _unhandled_input(event: InputEvent) -> void:
	if not selectable:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			var space_state := get_world_2d().direct_space_state
			var parameters := PhysicsPointQueryParameters2D.new()
			parameters.position = get_global_mouse_position()
			parameters.collide_with_areas = true
			parameters.collision_mask = ENEMY_MASK
			var colision_result := space_state.intersect_point(parameters)
			if not colision_result.is_empty() && colision_result[0].collider.get_parent() == self:
				print("Enemy clicked ", name)
				enemy_selected.emit(self)

func takeTurn():
	await get_tree().create_timer(0.5).timeout
	
	## For now AI is stupid and juste take random card
	var card_to_play:Card = hand.cards.filter(is_card_playable).pick_random()
	await animate_card_to_slot(card_to_play)
	hand.remove_card_from_hand(card_to_play)
	card_slot.receive_card(card_to_play)
	card_to_play.process_mode = Node.PROCESS_MODE_DISABLED ## I suppose disabling the full node will work as fine as disabling the colisionShape 
	play_card(card_to_play)

func play_card(card:Card) -> void:
	print("%s play %s" % [name, card.infos.title])
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
			print('test')
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
	has_played.emit()


func _on_area_2d_mouse_entered() -> void:
	if selectable:
		_is_hovered = true
		print("TODO Do something visually")
func _on_area_2d_mouse_exited() -> void:
	_is_hovered = false
