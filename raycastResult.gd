## Object return by raycast event 
## Return card/card_slot/deck
class_name RaycastResult
extends RefCounted

var card: Card = null
var card_slot: CardSlot = null
var deck: Deck = null

func _init(p_card: Card = null, p_card_slot: CardSlot = null, p_deck: Deck = null) -> void:
	card = p_card
	card_slot = p_card_slot
	deck = p_deck

## Pratique pour tester rapidement s'il y a eu au moins un hit
func has_any() -> bool:
	return card != null or card_slot != null or deck != null
