class_name GardeInterface extends CardInterface

@onready var message: Message = $Message

var selected_enemy:Player = null
var selected_card:CardInfos = null
var enemies:Array[Player]


func enter() -> void:
	super() # Execute parenter enter func
	player_action.card_type_played_index = Constant.CardTypes.find(Constant.GARDE)
	selected_enemy = null
	selected_card = null
	enemies = player_ref.get_vulnerable_enemies()



func check_result() -> void:
	player_action.enemy_selected_index = GameManager.instance.players.find(selected_enemy)
	player_action.card_type_selected_index = Constant.CardTypes.find(selected_card)
	if selected_enemy.hand.cards[0].infos == selected_card:
		print("kill ",selected_enemy)
		selected_enemy.kill()
		await message.display_text("Bravo!")
	else:
		await message.display_text("Nope!")
	validate()
