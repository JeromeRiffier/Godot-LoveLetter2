class_name PointableManager extends Node2D

const CONE_THRESHOLD:float = cos(deg_to_rad(45.0))
const WEIGHT:float = 2.0
const INPUT_COOLDOWN:float = 0.2

@onready var crosshair: Sprite2D = $Crosshair

var await_cooldown:bool = false:
	set(value):
		if value:
			await_cooldown = true
			await get_tree().create_timer(INPUT_COOLDOWN).timeout ## Is this spamming the tree with dead timers ?
			await_cooldown = false

var pointing_at:Pointable:
	set(value):
		pointing_at = value
		crosshair.visible = true if pointing_at else false


func _input(event: InputEvent) -> void:
	if await_cooldown:
		return
	if not event.is_action_pressed("right") and not event.is_action_pressed("left") and not event.is_action_pressed("down") and not event.is_action_pressed("up"):
		return
		
	var direction:Vector2 = Input.get_vector("left","right","up","down")
	await_cooldown = true
	
	var other_pointables := get_other_pointables()
	pointing_at = find_next_pointable(direction, other_pointables)
	move_pointer()

func get_other_pointables() -> Array[Pointable]:
	var other_pointables:Array[Pointable]
	var nodes: Array[Node] = get_tree().get_nodes_in_group("Pointable")
	other_pointables.assign(nodes)
	return other_pointables.filter(func (pointable:Pointable) -> bool: return pointable != pointing_at)

func find_next_pointable(direction:Vector2, pointables:Array[Pointable]) -> Pointable:
	##Indispensable de normalisé la direction pour les calculs suivants
	direction = direction.normalized()
	
	var nearest:Pointable = null
	var nearest_weight:float
	
	for pointable in pointables:
		## On récupére l'offset => le vecteur entre notre position actuel et le pointable
		var offset :Vector2= pointable.global_position - global_position
		
		## Le cosinus de l'angle entre la direction voulus et la direction du pointable
		var angle:float = offset.normalized().dot(direction) 
		## Si l'angle est inférieure au treshold on est en dehors du cone voulus donc on skip
		if  angle <=CONE_THRESHOLD:
			continue
		
		### Maintenant que l'angle est bon on va recupéré le poid du pointable pour trouvé le plus proche de la direction voulu:
		
		## Projection = la distance dans la direction voulus (pas la distance reel) [br] [b]Example[/b] si dir = droite, projection = a quelle point l'object est a droite du sujet
		var projection :float= offset.dot(direction) 
		## Lateral = l'autre distance, a quel point on s'ecarte de l'axe tracé par la direction [br] [b]Example[/b] si dir = droite, et le sujet ce trouve en haut a droite, lateral = a quelle distance il est en haut. [br][i]Cross renvoi un resultat positif si a droite de l'axe et negatif si a gauche donc on recup l'absolu puisqu'on a seulement besoin de la distance et pas de la directions[/i]
		var lateral: float = abs(offset.cross(direction)) 
		
		## Maintenant qu'on a ces 2 valeurs on les additionne mais en mutlipliant lateral (l'ecart de l'axe) par weight pour favorisé les pointables les plus aligné
		var weighted:float = projection + lateral * WEIGHT 
		
		if not nearest or weighted < nearest_weight:
			nearest_weight = weighted
			nearest = pointable
	
	## Si on a rien trouvé (pas de pointable dans le cone de direction) on retourne null
	if not nearest:
		return null
	## Si on a trouvé un pointable prometeur on le renvoi
	return nearest

func move_pointer() -> void:
	if not pointing_at:
		return
	global_position = pointing_at.global_position
