class_name PlayerAction extends RefCounted

var player_index:int
var player_peer_id:int
var card_type_played_index:int
var enemy_selected_index:int
var card_type_selected_index:int
var chancelier_card_destinations:ChancelierCardDestinations = ChancelierCardDestinations.new()


class ChancelierCardDestinations :
	var first:Constant.CHANCELIER_CARD_DESTINATION_ENUM
	var second:Constant.CHANCELIER_CARD_DESTINATION_ENUM
	var third:Constant.CHANCELIER_CARD_DESTINATION_ENUM




#func take_decision(card:Card) -> PlayerAction:
	#match card.infos:
		#Constant.PRINCESS, Constant.COMTESSE, Constant.SERVANTE, Constant.ESPIONNE:
			#print("Renvoi rien")
		#Constant.ROI, Constant.BARON, Constant.PRINCE, Constant.PRÊTRE:
			#print("Renvoi uniquement l'enemy")
			#var enemies := get_vulnerable_enemies()
			#var selected_player :Player = enemies.pick_random()
			#var enemy_index := GameManager.instance.get_player_index(selected_player)
			#decision.enemy_selected_index = enemy_index
		#Constant.GARDE:
			#print("Renvoi l'enemy et un type de carte")
			#
			#var enemies := get_vulnerable_enemies()
			#var selected_player :Player = enemies.pick_random()
			#var enemy_index := GameManager.instance.get_player_index(selected_player)
			#decision.enemy_selected_index = enemy_index
			#
			#var selected_card :CardInfos= Constant.CardTypesWithoutGuard.pick_random()
			#decision.card_type_selected_index = Constant.CardTypesWithoutGuard.find(selected_card)
		#Constant.CHANCELIER:
			#print("Renvoi la destination des 3 cartes (deck ou main)")
	#return decision
