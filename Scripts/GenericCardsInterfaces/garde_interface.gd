class_name GardeInterface extends CardInterface

@onready var message: Message = $Message

var selected_enemy:Player = null
var card_selected:CardInfos = null
var enemies:Array[Player]


func enter() -> void:
	super() # Execute parenter enter func
	selected_enemy = null
	card_selected = null
	enemies = player_ref.get_vulnerable_enemies()



func check_result() -> void:
	if selected_enemy.hand.cards[0].infos == card_selected:
		print("kill ",selected_enemy)
		selected_enemy.kill()
		await message.display_text("Bravo!")
	else:
		await message.display_text("Nope!")
	validate()
