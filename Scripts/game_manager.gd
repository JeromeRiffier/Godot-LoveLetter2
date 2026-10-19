class_name GameManager extends Node2D

@export var deck:Deck
@export var the_player:LocalPlayer
@export var ai_player_manager: AiPlayerManager
@export var network_player_manager: NetworkPlayerManager
@export var cards_used: CardsPlayed
@export var players_position_management: PlayersPositionManagement

@export_range(1, 5) var enemy_count:int = 3

var players: Array[Player] = []
var game_is_running:bool = true

func _ready() -> void:
	pass

func start_game() -> void:
	setup_players()
	deck.reset_deck()
	deck.shuffle()
	cards_used.reset()
	## Connect signals
	var realPlayerIndex := players.find_custom(func (player:Player) -> bool: return player is LocalPlayer)
	if realPlayerIndex != -1:
		players[realPlayerIndex].need_to_select_enemy.connect(manage_enemy_selection_state)
	for player in players:
		player.need_card.connect(give_card_to_player)
		player.return_card.connect(deck.take_back)
	#if deck:
		#deck.deck_is_empty.connect(func () -> void: game_is_running = false) 
	## start Round
	await deck.deck_is_ready
	#deck.shuffle()
	deck.put_one_appart()
	set_all_players_alive()
	await give_starting_cards()
	## manage Round
	while game_is_running:
		for player in players:
			if deck.cards.is_empty():
				game_is_running = false
				break
			if get_player_alive().size() <= 1:
				game_is_running = false
				break
			if not player.is_alive:
				continue
			await give_card_to_player(player)
			player.is_playing = true
			if player is not LocalPlayer:
				player.takeTurn()
			await player.has_played
			player.is_playing = false
	manage_end_of_round()

func setup_players() -> void:
	players.clear()
	
	ai_player_manager.spawn_ai_players(enemy_count)
	players.append_array(ai_player_manager.ai_players)
	
	network_player_manager.spawn_network_players()
	players.append_array(network_player_manager.network_players)
	
	players.append(the_player)
	
	players.shuffle()
	
	players_position_management.position_players(players)


func give_starting_cards() -> void:
	for player in players:
		await give_card_to_player(player)

func give_card_to_player(player:Player) -> void:
	var card := deck.draw_card()
	if not card:
		print("End of game")
	else:
		await player.draw_card(card)

func manage_end_of_round() -> void:
	print("The game as endend, count points, reset deck if needed, ask if ready etc")

func set_all_players_alive() -> void:
	for player in players:
		player.is_alive = true

func manage_enemy_selection_state(should_be_selectable:bool) -> void:
	var enemies:Array[AiPlayer]
	enemies.assign(get_tree().get_nodes_in_group("Player").filter(func (enemy:Player) -> bool: return enemy is AiPlayer and enemy.is_alive))
	for enemy in enemies:
		enemy.selectable = should_be_selectable
	print("manage_enemy_selection_state")

func get_player_alive() -> Array[Player]:
	var alive_players: Array[Player]
	alive_players.assign( players.filter( func (player:Player) -> bool: return player.is_alive) )
	return alive_players
