class_name Hand extends Node2D


const CARD_WIDTH:int = 80

@onready var example_card: Card = $Example_card

var cards: Array[Card] = []

func _ready() -> void:
	example_card.queue_free()

func add_card_to_hand(card:Card) -> void:
	if card not in cards:
		cards.push_front(card)
		await update_hand_positions()
	
func reposition_card(card:Card):
	animate_card_to_position(card, card.position_in_hand) 

func remove_card_from_hand(card:Card) -> void:
		cards.erase(card)
		await update_hand_positions()
		

func update_hand_positions() -> void:
	for i in range(cards.size()):
		var new_position =  Vector2(calculate_card_positions_x(i), global_position.y)
		var card := cards[i]
		card.position_in_hand = new_position
		await animate_card_to_position(card, new_position)
func calculate_card_positions_x(index:int) -> float:
	var total_width := cards.size() * CARD_WIDTH
	var x_offset := global_position.x + index * CARD_WIDTH - total_width / 2.0 + (CARD_WIDTH / 2.0)
	return x_offset
func animate_card_to_position(card:Card, new_position:Vector2) -> void:
	var tween = create_tween()
	tween.tween_property(card, "global_position", new_position, 0.3)
	await tween.finished
