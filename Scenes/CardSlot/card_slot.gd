class_name CardSlot extends Node2D

@export var slot_owner:Player

var cards_played:Array[Card]

func receive_card(card:Card) -> void:
	card.selectable = false
	card.z_index = 0
	cards_played.push_front(card)
	card.reparent(self)
	card.show_card()
	var tween := create_tween()
	tween.set_parallel()
	tween.tween_property(card, "global_position", global_position, 0.2 )
	tween.tween_property(card, "global_rotation", global_rotation, 0.2 )
	await tween.finished
	self.move_child(card, self.get_child_count()) ## Used to reposition under the deck visually
	card.process_mode = Node.PROCESS_MODE_DISABLED ## I suppose disabling the full node will work as fine as disabling the colisionShape 
