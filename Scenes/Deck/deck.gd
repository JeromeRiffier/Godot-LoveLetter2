class_name Deck extends Node2D

const CARD_SCENE = preload("uid://c7em3t5lv5vr0")


signal deck_clicked
signal deck_is_empty
@onready var cards :Array[Card]

func _ready() -> void:
	for cardInfo in Constant.BaseDeck:
		var card :Card = CARD_SCENE.instantiate()
		add_child(card)
		card.set_infos(cardInfo)
		cards.push_front(card)

func shuffle() -> void:
	cards.shuffle()

func draw_card() -> Card:
	if cards.is_empty():
		deck_is_empty.emit()
		print('No more cards')
		return
	return cards.pop_front()

func take_back(card:Card) -> void:
	var tween = create_tween()
	tween.tween_property(card, "global_position", global_position, 0.3)
	cards.push_back(card)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			var space_state := get_world_2d().direct_space_state
			var parameters := PhysicsPointQueryParameters2D.new()
			parameters.position = get_global_mouse_position()
			parameters.collide_with_areas = true
			parameters.collision_mask = Constant.DECK_MASK
			var colision_result := space_state.intersect_point(parameters)
			if not colision_result.is_empty():
				print("deck clicked")
				deck_clicked.emit()
