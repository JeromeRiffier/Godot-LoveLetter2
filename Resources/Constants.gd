class_name Constant

const MIN_WINDOW_SIZE:Vector2= Vector2i(900.0,800.0)


const PRINCESS: CardInfos = preload("uid://mxkwt1ftts6c")
const COMTESSE: CardInfos = preload("uid://chy6weh1ghk1s")
const ROI: CardInfos = preload("uid://rjnbcqdlwdu8")
const CHANCELIER: CardInfos = preload("uid://bw14015f1hm28")
const PRINCE: CardInfos = preload("uid://7r3sa6gbsvm6")
const SERVANTE: CardInfos = preload("uid://busdtqquvp16i")
const BARON: CardInfos = preload("uid://bqbljbxuhm6sw")
const PRÊTRE: CardInfos = preload("uid://bw51xf052x1ah")
const GARDE: CardInfos = preload("uid://dplbbqbi70nc4")
const ESPIONNE: CardInfos = preload("uid://dsgiyq5mteexx")

const BaseDeck: Array[CardInfos] = [
		PRINCESS, 
		COMTESSE, 
		ROI, 
		CHANCELIER, 
		CHANCELIER, 
		PRINCE, 
		PRINCE, 
		SERVANTE, 
		SERVANTE, 
		BARON, 
		BARON, 
		PRÊTRE, 
		PRÊTRE, 
		GARDE, 
		GARDE, 
		GARDE, 
		GARDE, 
		GARDE, 
		GARDE, 
		ESPIONNE, 
		ESPIONNE,
		
		CHANCELIER, 
	]
const CardTypes: Array[CardInfos] = [
		PRINCESS, 
		COMTESSE, 
		ROI, 
		CHANCELIER, 
		PRINCE, 
		SERVANTE, 
		BARON, 
		PRÊTRE, 
		GARDE, 
		ESPIONNE, 
	]
const CardTypesWithoutGuard: Array[CardInfos] = [
		PRINCESS, 
		COMTESSE, 
		ROI, 
		CHANCELIER, 
		PRINCE, 
		BARON, 
		SERVANTE, 
		PRÊTRE, 
		ESPIONNE, 
	]

enum CardValues{
		Princesse=9,
		Comtesse=8,
		Roi=7,
		Chancelier=6,
		Prince=5,
		Baron=4,
		Servante=3,
		Prêtre=2,
		Garde=1,
		Espionne=0
	}

enum CHANCELIER_CARD_DESTINATION_ENUM {
	DECK,
	HAND
}
#Colision Masks
const DECK_MASK:int = 4
const ENEMY_MASK:int = 8
const PLAYER_MASK:int = 16
const POINTABLE_MASK:int = 32

#Cards constants
const CARD_WIDTH:int = 80
const CARD_MASK:int = 1
const CARD_SLOT_MASK:int = 2

#Deck constants
const DECK_MARGING_LEFT:int = 130
const DECK_MARGING_BOTTOM:int = 130
const MYSTERY_CARD_MARGIN:int = -120

#Enemy constants

const ENEMY_Y_POS:int = 85
const ENEMY_WIDTH:int = 160

#Players position contants
const LOCAL_PLAYER_MARGING_BOTTOM:int = 100


const CHARS := "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
static func random_string(length: int) -> String:
	var result := ""
	for i in length:
		result += CHARS[randi() % CHARS.length()]
	return result
