class_name CardSlot extends Node2D

@export var slot_owner:Player

var cards_played:Array[Card]

func receive_card(card:Card) -> void:
	for card_played in cards_played:
		card_played.z_index -= 1
	cards_played.push_front(card)
