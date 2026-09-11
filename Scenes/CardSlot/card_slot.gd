class_name CardSlot extends Node2D

@export var slot_owner:Player

var cards_played:Array[Card]

func receive_card(card:Card) -> void:
	card.z_index = 0
	cards_played.push_front(card)
	card.reparent(self)
	self.move_child(card, self.get_child_count()) ## Used to reposition under the deck visually
