class_name PointableManager extends Node2D

const CONE_THRESHOLD:float = cos(deg_to_rad(45.0))
const WEIGHT:float = 2.0
const INPUT_COOLDOWN:float = 0.05

@onready var crosshair: Sprite2D = $Crosshair

var controller_mode:bool = false:
	set(value):
		if value == controller_mode:
			return
		controller_mode = value
		crosshair.visible = value
		changed_mode.emit(value)
		if not value:
			pointing_at = null

var await_cooldown:bool = false:
	set(value):
		if value:
			await_cooldown = true
			await get_tree().create_timer(INPUT_COOLDOWN).timeout ## Is this spamming the tree with dead timers ?
			await_cooldown = false

var pointing_at:Pointable:
	set(value):
		if value == pointing_at:
			return
		if pointing_at:
			pointing_at.is_selected.disconnect(_on_pointing_at_selected)
			pointing_at.unpoint_at()
		pointing_at = value
		if value:
			pointing_at.is_selected.connect(_on_pointing_at_selected)
			crosshair.visible = true
			value.point_at()
		else:
			crosshair.visible = false
var dragging:Pointable

signal changed_mode(is_controller_mode:bool)
signal started_dragging(position:Vector2, pointable:Pointable)
signal stopped_dragging(position:Vector2, pointable:Pointable)

#func _input(event: InputEvent) -> void:
	#return
	#if event is InputEventMouseButton:
		#controller_mode = false
		#return
	#if event.is_action_pressed("right") or event.is_action_pressed("left") or event.is_action_pressed("down") or event.is_action_pressed("up"):
		#controller_mode = true
		#return

var click_start_position:Vector2 = Vector2.INF
var is_dragging:bool = false

func _unhandled_input(event: InputEvent) -> void:
	if await_cooldown:
		return
	
	#region dragging management
	if event is InputEventMouseMotion and click_start_position != Vector2.INF and not is_dragging:
		var pointable_under_mouse := find_pointable_under_mouse()
		if pointable_under_mouse and pointable_under_mouse.is_draggable:
			is_dragging = true
			dragging = pointable_under_mouse
			started_dragging.emit(get_global_mouse_position(), dragging)
			dragging.start_behing_dragged()
			click_start_position = get_global_mouse_position()
		else:
			click_start_position = Vector2.INF
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_released() and is_dragging:
		is_dragging = false
		click_start_position = Vector2.INF
		stopped_dragging.emit(get_global_mouse_position(), dragging)
		dragging.stop_behing_dragged()
		return
	#endregion
	
	#region click management
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		click_start_position = event.position
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_released() and click_start_position == event.position:
		handle_click(event)
		click_start_position = Vector2.INF
		return
	#endregion

	if event.is_action_pressed("validate") and pointing_at:
		pointing_at.validate()
		get_viewport().set_input_as_handled()
		return

	if not event.is_action_pressed("right") and not event.is_action_pressed("left") and not event.is_action_pressed("down") and not event.is_action_pressed("up"):
		return
	get_viewport().set_input_as_handled()

	var direction:Vector2 = Input.get_vector("left","right","up","down")
	await_cooldown = true
	
	var other_pointables := get_other_pointables()
	var next_pointable := find_next_pointable(direction, other_pointables)
	if next_pointable:
		pointing_at = next_pointable
		move_pointer()

func handle_click(_event:InputEventMouseButton) -> void:
	var pointable := find_pointable_under_mouse()
	if not pointable:
		pointing_at = null
		return
	if pointable == pointing_at:
		pointing_at.validate()
		return
	pointing_at = pointable
	move_pointer()

func _process(delta: float) -> void:
	if is_dragging and dragging:
		var parent := dragging.get_parent()
		if parent is Node2D:
			parent.global_position = get_global_mouse_position()


func get_pointables() -> Array[Pointable]:
	var pointables:Array[Pointable]
	var nodes: Array[Node] = get_tree().get_nodes_in_group("Pointable")
	pointables.assign(nodes)
	return pointables.filter(func (pointable:Pointable) -> bool: return  pointable.is_pointable)

func get_other_pointables() -> Array[Pointable]:
	var other_pointables := get_pointables()
	return other_pointables.filter(func (pointable:Pointable) -> bool: return pointable != pointing_at and pointable.is_pointable)

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

func find_pointable_under_mouse() -> Pointable:
	var pointables:Array[Pointable]
	var space_state := get_world_2d().direct_space_state
	var parameters := PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = Constant.POINTABLE_MASK
	var results := space_state.intersect_point(parameters)
	pointables.assign(
		results.map(
			func (element:Dictionary) -> Pointable: return element.collider
		).filter(
			func (pointable:Pointable) -> bool: return pointable.is_pointable
		)
	)
	if pointables.is_empty():
		return null
	return pointables[0]



func move_pointer() -> void:
	if not pointing_at:
		return
	global_position = pointing_at.global_position


## Used to preselect a pointable to highlight 
## [br] Highlight the pointable the most left
func pre_point_to_pointable() -> void:
	var pointables := get_pointables()
	var leftest:Pointable = null
	for pointable in pointables:
		if not leftest or pointable.global_position.x < leftest.global_position.x:
			leftest = pointable
	if leftest:
		point_to(leftest)

## Force pointer manager to point to a specific pointable
func point_to(pointable:Pointable) -> void:
	if not controller_mode:
		return
	pointing_at = pointable
	move_pointer()

func _on_pointing_at_selected() -> void:
	pointing_at = null
