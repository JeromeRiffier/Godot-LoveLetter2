class_name GameManager extends Node2D

@export var deck:Deck
@export var the_player:Player
@onready var enemy: Enemy = $"../Enemy"
@onready var enemy_2: Enemy = $"../Enemy2"
@onready var enemy_3: Enemy = $"../Enemy3"

var players: Array[Player]
var game_is_running:bool = true

func _ready() -> void:
	#region debug For debug only
	players.assign( get_tree().get_nodes_in_group("Player") )
	await get_tree().create_timer(0.5).timeout
	 #endregion
	## Connect signals
	#if deck:
		#deck.deck_is_empty.connect(func () -> void: game_is_running = false) 
	## start Round
	give_starting_cards()
	## manage Round
	while game_is_running:
		for player in players:
			if deck.cards.is_empty():
				game_is_running = false
				break
			give_card_to_player(player)
			player.is_playing = true
			if player is Enemy:
				player.takeTurn()
			await player.has_played
			player.is_playing = false
	manage_end_of_round()
func give_starting_cards() -> void:
	for player in players:
		give_card_to_player(player)

func give_card_to_player(player:Player) -> void:
	var card = deck.draw_card()
	if not card:
		print("End of game")
	else:
		player.draw_card(card)

func manage_end_of_round() -> void:
	print("The game as endend, count points, reset deck if needed, ask if ready etc")
