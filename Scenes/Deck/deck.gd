class_name Deck extends Node2D

const CARD_SCENE = preload("uid://c7em3t5lv5vr0")


signal deck_is_ready
signal deck_clicked
signal deck_is_empty
@onready var cards :Array[Card]
var mystery_card:Card

func update_cards_position() -> void:
	for index in range(cards.size()):
		var offset:int = cards.size() - index
		cards[index].position = Vector2(-offset, -offset*0.5)

func _ready() -> void:
	for cardInfo in Constant.BaseDeck:
		var card :Card = CARD_SCENE.instantiate()
		add_child(card)
		card.set_infos(cardInfo)
		card.hide_card()
		cards.push_front(card)
		update_cards_position()
		await get_tree().create_timer(0.02).timeout
	deck_is_ready.emit()

func shuffle() -> void:
	cards.shuffle()

func draw_card() -> Card:
	if cards.is_empty():
		deck_is_empty.emit()
		print('No more cards')
		return
	var card :Card = cards.pop_front()
	card.show_card()
	update_cards_position()
	return card

func take_back(card:Card) -> void:
	card.global_position = global_position
	card.reparent(self)
	self.move_child(card, 0) ## Used to reposition under the deck visually
	card.hide_card()
	cards.push_back(card)
	update_cards_position()

func put_one_appart() -> void:
	var tween = create_tween()
	var random_card:Card = cards.pick_random()
	cards.erase(random_card)
	tween.set_parallel()
	tween.tween_property(random_card, "global_position:y", self.global_position.y + Constant.MYSTERY_CARD_MARGIN , 0.5)
	tween.tween_property(random_card, "rotation_degrees", 90, 0.5)
	await tween.finished
	

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
				deck_clicked.emit()
