class_name Deck extends Node2D

const CARD_SCENE = preload("uid://c7em3t5lv5vr0")

@onready var cards = Constant.BaseDeck.duplicate()
@export var player_hand:PlayerHand

func _ready() -> void:
	cards.shuffle()

func draw_card() -> void:
	if cards.is_empty():
		print('No more cards')
		return
	print('Draw card')
	var card :Card = CARD_SCENE.instantiate()
	var infos = cards.pop_front()
	add_child(card)
	card.set_infos(infos)
	
	await get_tree().create_timer(0.1).timeout
	player_hand.add_card_to_hand(card)
