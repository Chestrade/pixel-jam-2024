extends CharacterBody2D
@export_category("Movement")

## The speed at which the Angler Fish will move while in the Wandering state.
@export var wanderSpeed : float = 300

## The speed at which the Angler Fish will move while in the Wandering state.
@export var chaseSpeed : float = 400

## Refer the Angler fish's navigation agent 2D node.
@export var nav_agent : NavigationAgent2D

## Points that the Angler fish will pick at random while in the Wandering State.
@export var markers : Array[Marker2D] = []

var speed : float = 300

@export_category("Health")
## The color of the lights that show the amount of health left.
@export var  healthColors : Array[Color] = []
## The angler's fish health
@export_range(0, 100) var health

# Head light settings
@onready var headLight : PointLight2D = $Light/HeadLight
@onready var lightTimer : Timer = $Light/LightTimer
var minFlickerAmount : float = 10
var maxFlickerAmount : float = 20 # Interval in seconds
var currentMarkerIndex = -1
var isReachingTarget : bool = false

var target_node = null
var trashTarget = null

enum STATE {WANDERING, CHASE, EAT}
var currentState : STATE

func _ready() -> void:
	SetState(STATE.WANDERING)
	nav_agent.path_desired_distance = 4
	nav_agent.target_desired_distance = 4
	
	#Set health and light parameters
	health = 100
	headLight.set_color(healthColors[0]) 
	maxFlickerAmount = 10
	lightTimer.start()

func _process(_delta: float) -> void:
	StateUpdate()
	
	# Temporary shit for testing
	if Input.is_key_pressed(KEY_J): 
		setHealth(10)
		print(health)

func setHealth(damage : int):
	health -= damage
	if health >= 75:
		headLight.set_color(healthColors[0]) 
		maxFlickerAmount = 10
	elif health <75 and health >= 50:
		headLight.set_color(healthColors[1])
		maxFlickerAmount = 12.5
	elif health <50 and health >=25:
		headLight.set_color(healthColors[2]) 
		maxFlickerAmount = 17.5
	elif health <25:
		headLight.set_color(healthColors[3]) 
		maxFlickerAmount = 23
	
	#Clamping health
	if health > 100:
		health = 100
	if health < 0:
		health = 0

func StateUpdate() -> void:
	match currentState:
		STATE.WANDERING:
			if isReachingTarget:
				if nav_agent.is_navigation_finished():
					isReachingTarget = false
					currentMarkerIndex = randi_range(0,markers.size() -1)
					nav_agent.target_position = markers[currentMarkerIndex].global_position
					
			else:
				if nav_agent.is_navigation_finished():
					isReachingTarget = true
					nav_agent.target_position = markers[currentMarkerIndex].global_position
					
		STATE.CHASE:
			nav_agent.target_position = target_node.global_position
		STATE.EAT:
			pass
			#nav_agent.target_position = trashTarget.global_position
	
	if nav_agent.is_navigation_finished(): #if the nav agent reached its target
		return
	
	var axis : Vector2 = to_local(nav_agent.get_next_path_position()).normalized()
	velocity = axis * speed
	move_and_slide()

func SetState(newState : STATE) -> void:
	currentState = newState
	match currentState:
		STATE.WANDERING:
			speed = wanderSpeed
		STATE.CHASE:
			speed = chaseSpeed
		STATE.EAT:
			speed = 10

func recalc_path() -> void:
	if target_node and currentState == STATE.CHASE:
		nav_agent.target_position = target_node.global_position
	elif currentState == STATE.WANDERING:
		nav_agent.target_position = markers[currentMarkerIndex].global_position

# Signals

func _on_timer_timeout() -> void:
	recalc_path()

func _on_area_2d_area_entered(area: Area2D) -> void:
	SetState(STATE.CHASE)
	target_node = area.owner

func _on_area_2d_area_exited(area: Area2D) -> void:
	if area.owner == target_node:
		target_node = null
	SetState(STATE.WANDERING)

func _on_light_timer_timeout() -> void:
	var flicker = randf_range(minFlickerAmount, maxFlickerAmount)
	headLight.energy = flicker


func _on_trash_pickup_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("Trash"):
		print("Angler fish ate some trash.")
		#trashTarget = area.node
		#SetState(STATE.EAT)
