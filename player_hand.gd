class_name PlayerHand extends Node2D


const HAND_COUNT:int = 5
const CARD_WIDTH:int = 80
const HAND_Y_POS:int = 80
@onready var card_manager: CardManager = $"../CardManager"

var player_hand: Array[Card] = []
var center_screen_x:int

func _ready() -> void:
	center_screen_x = get_viewport_rect().size.x / 2
	const CARD = preload("uid://c7em3t5lv5vr0")
	for i in range(HAND_COUNT):
		var new_card = CARD.instantiate()
		if card_manager:
			card_manager.add_child(new_card)
		add_card_to_hand(new_card)

func add_card_to_hand(card:Card):
	if card not in player_hand:
		player_hand.push_front(card)
		update_hand_positions()
	else:
		animate_card_to_position(card, card.position_in_hand) 

func update_hand_positions() -> void:
	for i in range(player_hand.size()):
		var new_position =  Vector2(calculate_card_positions_x(i), get_viewport_rect().size.y - HAND_Y_POS)
		var card := player_hand[i]
		card.position_in_hand = Vector2.ZERO
		animate_card_to_position(card, new_position)

func calculate_card_positions_x(index:int) -> int:
	var total_width := player_hand.size() * CARD_WIDTH
	var x_offset := center_screen_x + index * CARD_WIDTH - total_width /2
	return x_offset

func animate_card_to_position(card:Card, new_position:Vector2) -> void:
	var tween = create_tween()
	tween.tween_property(card, "position", new_position, 0.1)

func remove_card_from_hand(card:Card) -> void:
	if card in player_hand:
		player_hand.erase(card)
		update_hand_positions()
