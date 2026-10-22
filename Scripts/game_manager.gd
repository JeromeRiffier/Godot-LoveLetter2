class_name GameManager extends Node2D

static var instance:GameManager

@export var deck:Deck
@export var the_player:LocalPlayer
@export var ai_player_manager: AiPlayerManager
@export var network_player_manager: NetworkPlayerManager
@export var cards_used: CardsPlayed
@export var players_position_management: PlayersPositionManagement

@export_range(1, 5) var enemy_count:int = 3

var players: Array[Player] = []
var game_is_running:bool = true

#region singleton
func _enter_tree() -> void:
	if instance != null and instance != self:
		queue_free()  # un doublon existe déjà
		return
	instance = self

func _exit_tree() -> void:
	if instance == self:
		instance = null
#endregion

func start_game(players_list:Array[PlayerElement]) -> void:
	setup_players(players_list)
	deck.reset_deck()
	deck.shuffle()
	cards_used.reset()
	if not multiplayer.is_server():
		print('ici')
	## Connect signals
	var realPlayerIndex := players.find_custom(func (player:Player) -> bool: return player is LocalPlayer)
	if realPlayerIndex != -1:
		players[realPlayerIndex].need_to_select_enemy.connect(manage_enemy_selection_state)
		players[realPlayerIndex].set_label()
	for player in players:
		if not player.need_card.is_connected(give_card_to_player):
			player.need_card.connect(give_card_to_player)
		if not player.return_card.is_connected(deck.take_back):
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
			if get_alive_players().size() <= 1:
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

func setup_players(players_list:Array[PlayerElement]) -> void:
	players.clear()
	for playerElelement in players_list:
		match playerElelement.type:
			PlayerElement.PLAYER_TYPE.IA:
				var aiPlayer := ai_player_manager.spawn_ai_player(playerElelement)
				players.append(aiPlayer)
			PlayerElement.PLAYER_TYPE.REAL:
				if playerElelement.id == multiplayer.get_unique_id():
					the_player.id = playerElelement.id
					the_player.name = playerElelement.name
					players.append(the_player)
				else:
					var networkPlayer := network_player_manager.spawn_network_player(playerElelement)
					players.append(networkPlayer)
	players_position_management.position_players()

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
	var enemies:Array[Player]
	enemies.assign(get_tree().get_nodes_in_group("Player").filter(func (enemy:Player) -> bool: return enemy is Player and enemy.is_alive and enemy.id != multiplayer.get_unique_id()))
	for enemy in enemies:
		enemy.selectable = should_be_selectable

func get_alive_players() -> Array[Player]:
	var alive_players: Array[Player]
	alive_players.assign( players.filter( func (player:Player) -> bool: return player.is_alive) )
	return alive_players
