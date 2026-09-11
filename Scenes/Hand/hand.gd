class_name Hand extends Node2D


@onready var example_card: Card = $Example_card

var cards: Array[Card] = []

var _update_positions_requested: bool = false
var _updating_positions: bool = false

signal card_repositioned


func _ready() -> void:
	example_card.queue_free()

func add_card_to_hand(card: Card) -> void:
	if card not in cards:
		cards.push_front(card)
		await update_hand_positions()

func reposition_card(card: Card) -> void:
	await animate_card_to_position(card, card.position_in_hand)

func remove_card_from_hand(card: Card) -> void:
	cards.erase(card)
	await update_hand_positions()

func update_hand_positions() -> void:
	_update_positions_requested = true

	# Un repositionnement est déjà en cours : on se contente d'attendre sa fin.
	if _updating_positions:
		await card_repositioned
		return

	_updating_positions = true
	# Laisse les appels du même frame s'accumuler en une seule passe.
	await get_tree().process_frame

	while _update_positions_requested:
		_update_positions_requested = false
		await _apply_positions()

	_updating_positions = false
	card_repositioned.emit()

func _apply_positions() -> void:
	if cards.is_empty():
		return

	var tween := create_tween().set_parallel(true)
	for i in cards.size():
		var new_position := Vector2(calculate_card_positions_x(i), global_position.y)
		cards[i].position_in_hand = new_position
		tween.tween_property(cards[i], "global_position", new_position, 0.3)
	await tween.finished

func calculate_card_positions_x(index: int) -> float:
	var total_width := cards.size() * Constant.CARD_WIDTH
	return global_position.x + index * Constant.CARD_WIDTH - total_width / 2.0 + (Constant.CARD_WIDTH / 2.0)

func animate_card_to_position(card: Card, new_position: Vector2) -> void:
	var tween := create_tween()
	tween.tween_property(card, "global_position", new_position, 0.3)
	await tween.finished
