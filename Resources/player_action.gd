class_name PlayerAction extends RefCounted

var player_index:int
var player_peer_id:int
var card_type_played_index:int
var enemy_selected_index:int
var card_type_selected_index:int
var chancelier_card_destinations:ChancelierCardDestinations = ChancelierCardDestinations.new()


func to_dict() -> Dictionary:
	return {
		"player_index":player_index,
		"player_peer_id":player_peer_id,
		"card_type_played_index":card_type_played_index,
		"enemy_selected_index":enemy_selected_index,
		"card_type_selected_index":card_type_selected_index,
		"chancelier_card_destinations":chancelier_card_destinations.to_dict(),
	}

static func from_dict(data: Dictionary) -> PlayerAction:
	var element := PlayerAction.new()
	element.player_index = data.player_index
	element.player_peer_id = data.player_peer_id
	element.card_type_played_index = data.card_type_played_index
	element.enemy_selected_index = data.enemy_selected_index
	element.card_type_selected_index = data.card_type_selected_index
	element.chancelier_card_destinations = ChancelierCardDestinations.from_dict( data.chancelier_card_destinations)
	return element


class ChancelierCardDestinations :
	var first:Constant.CHANCELIER_CARD_DESTINATION_ENUM
	var second:Constant.CHANCELIER_CARD_DESTINATION_ENUM
	var third:Constant.CHANCELIER_CARD_DESTINATION_ENUM

	
	func to_dict() -> Dictionary:
		return {
			"first":first,
			"second":second,
			"third":third,
		}

	static func from_dict(data: Dictionary) -> ChancelierCardDestinations:
		var element := ChancelierCardDestinations.new()
		element.first = data.first
		element.second = data.second
		element.third = data.third
		return element
