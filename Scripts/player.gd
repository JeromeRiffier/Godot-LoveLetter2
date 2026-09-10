## Base Player class 
## Used by RealPlayer and PlayerAI
class_name Player extends Marker2D

const CARD_MASK = 1
const CARD_SLOT_MASK = 2
@onready var hand: Hand = $Hand
@onready var card_slot: CardSlot = $CardSlot
@onready var player_sprite: PlayerSprite = $PlayerSprite


var is_playing:bool = false
var is_protected:bool = false:
	set(value):
		is_protected = value
		player_sprite.is_protected = value
var is_alive:bool = false:
	set(value):
		is_alive = value
		player_sprite.is_dead = !value
var as_played_spy:bool = false:
	set(value):
		as_played_spy = value
		player_sprite.is_spy = value

signal has_played(emiter:Player)
signal need_card(emiter:Player)

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

func is_card_playable(card:Card) -> bool:
	var is_roi_or_prince:bool = [Constant.PRINCE, Constant.ROI].has(card.infos)
	var hand_contain_comtesse:bool = hand.cards.any(func (element:Card) -> bool: return element.infos == Constant.COMTESSE)
	if is_roi_or_prince and hand_contain_comtesse:
		return false
	return true

func kill() -> void:
	is_alive = false
	print(self," is dead")

func discard(card:Card) -> void:
	if card.infos == Constant.PRINCESS:
		kill()
	hand.remove_card_from_hand(card)
	animate_card_to_slot(card)
	if is_alive:
		need_card.emit(self)

func animate_card_to_slot(card:Card) -> void:
	card.show_card()
	var tween = create_tween()
	tween.tween_property(card, "global_position", card_slot.global_position, 0.2 )
	await tween.finished
	print("test")
