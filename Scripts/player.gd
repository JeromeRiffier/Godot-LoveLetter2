## Base Player class 
## Used by RealPlayer and PlayerAI
class_name Player extends Marker2D

const CARD_MASK = 1
const CARD_SLOT_MASK = 2
@onready var hand: Hand = $Hand
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var card_slot: CardSlot = $CardSlot


var is_playing:bool = false
var is_protected:bool = false
var is_alive:bool = false
var as_played_spy:bool = false

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

func is_card_playable(card:Card) -> bool:
	var is_roi_or_prince:bool = [Constant.PRINCE, Constant.ROI].has(card.infos)
	var hand_contain_comtesse:bool = hand.cards.any(func (element:Card) -> bool: return element.infos == Constant.COMTESSE)
	if is_roi_or_prince and hand_contain_comtesse:
		return false
	return true
