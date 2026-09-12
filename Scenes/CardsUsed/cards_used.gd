class_name CardsPlayed extends Node2D

const CARD = preload("uid://c7em3t5lv5vr0")
const CONTAINER_X_POSITION = 60
const CARD_PLAYED_HEIGHT = 50
const CARD_PLAYED_WIDTH = 40

@onready var cards_container: Node2D = $CardsContainer

var clone_deck:Array[Card]

func _ready() -> void:
	var deck :Deck = get_tree().get_first_node_in_group("Deck")
	if deck:
		deck.deck_is_ready.connect(construct_from_real_deck)
	else:
		construct_for_debug()

	var players:Array[Player]
	players.assign( get_tree().get_nodes_in_group("Player"))
	for player in players:
		player.has_played.connect(card_used)
		player.has_discarded.connect(card_used)
	
	cards_container.global_position = Vector2(get_tree().root.size.x - CONTAINER_X_POSITION, get_tree().root.size.y /2.0)

## This func search a card in clone_deck that correspond to the one used but as not already been marked as used by opacity
## Using modulate.a == 1 is kind of hacky, I should use a better approach when refactoring
func card_used(player:Player, card_played:Card) -> void:
	var index:int = clone_deck.find_custom(func (card:Card) -> bool: return card.infos == card_played.infos && card.modulate.a == 1)
	if index != -1:
		clone_deck[index].modulate.a = 0.5

func construct_from_real_deck(deck_cards:Array[Card]) -> void:
	for deck_card in deck_cards:
		var card:Card = CARD.instantiate()
		card.scale = Vector2(0.5, 0.5)
		cards_container.add_child(card)
		card.set_infos(deck_card.infos)
		clone_deck.append(card)
	
	position_cards()

func construct_for_debug() -> void:
	for cardInfo in Constant.BaseDeck:
		var card:Card = CARD.instantiate()
		card.scale = Vector2(0.5, 0.5)
		cards_container.add_child(card)
		card.set_infos(cardInfo)
		clone_deck.append(card)
		
	position_cards()


func position_cards() -> void:
	## Position Y
	var full_height := _get_max_card_value() * CARD_PLAYED_HEIGHT
	for card in clone_deck:
		card.position.y = (CARD_PLAYED_HEIGHT * card.infos.value * -1.0 ) + full_height / 2.0
	
	## Position X
	for value in range(_get_max_card_value()):
		var cards_with_value := _get_cards_with_value(value)
		for index in range(cards_with_value.size()):
			cards_with_value[index].position.x = index * CARD_PLAYED_WIDTH * -1

func _get_max_card_value() -> int:
	var max_value := 0
	for card in clone_deck:
		if card.infos.value > max_value:
			max_value = card.infos.value
	return max_value

func _get_cards_with_value(value:int) -> Array[Card]:
	return clone_deck.filter(func (card:Card) -> bool: return card.infos.value == value)

func _number_of_cards_with_value(value:int) -> int:
	return _get_cards_with_value(value).size()
