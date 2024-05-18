extends CharacterBody2D
class_name AnglerFish
@export_category("Movement")

## The speed at which the Angler Fish will move while in the Wandering state.
@export var wanderSpeed : float = 80

## The speed at which the Angler Fish will move while in the Wandering state.
@export var chaseSpeed : float = 250

## Refer the Angler fish's navigation agent 2D node.
@export var nav_agent : NavigationAgent2D

## Refer the player node
@export var player : CharacterBody2D

## Points that the Angler fish will pick at random while in the Wandering State.
#@export var markers : Array[Marker2D] = []

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
var light_to_sprite_rel_pos_x : float


# Audio Stuff
@onready var horrorSounds : AudioStreamPlayer2D = $"Audio Streams/Horror Sounds"
@onready var splashSounds : AudioStreamPlayer2D = $"Audio Streams/Splash Sounds"

var target_node = null
var trashTarget = null

enum STATE {WANDERING, CHASE, EAT}
var currentState : STATE

func _ready() -> void:
	SetState(STATE.WANDERING)
	nav_agent.path_desired_distance = 4
	nav_agent.target_desired_distance = 4
	
	target_node = player
	
	light_to_sprite_rel_pos_x = $Light/HeadLight.position.x - $AnimatedSprite2D.position.x
	
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
	
	# Flip sprite and HeadLight according to direction of movement
	if velocity.x != 0:
		$AnimatedSprite2D.flip_h = velocity.x < 0
		if $AnimatedSprite2D.is_flipped_h():
			$Light/HeadLight.position.x = $AnimatedSprite2D.position.x - light_to_sprite_rel_pos_x
		else:
			$Light/HeadLight.position.x = $AnimatedSprite2D.position.x + light_to_sprite_rel_pos_x

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
			nav_agent.target_position = target_node.global_position
			#Old Wandering State Code with Waypoints
			#if isReachingTarget:
				#if nav_agent.is_navigation_finished():
					#isReachingTarget = false
					#currentMarkerIndex = randi_range(0,markers.size() -1)
					#nav_agent.target_position = markers[currentMarkerIndex].global_position
					#
			#else:
				#if nav_agent.is_navigation_finished():
					#isReachingTarget = true
					#nav_agent.target_position = markers[currentMarkerIndex].global_position
				
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
			horrorSounds.play()
			splashSounds.play()
		STATE.EAT:
			speed = 10

func recalc_path() -> void:
	nav_agent.target_position = target_node.global_position
	
	#if target_node and currentState == STATE.CHASE:
		#nav_agent.target_position = target_node.global_position
	#elif currentState == STATE.WANDERING:
		#nav_agent.target_position = markers[currentMarkerIndex].global_position

## Signals

func _on_timer_timeout() -> void:
	recalc_path()	

func _on_area_2d_area_exited(area: Area2D) -> void:
	if area.owner == target_node:
		SetState(STATE.WANDERING)
	

func _on_light_timer_timeout() -> void:
	var flicker = randf_range(minFlickerAmount, maxFlickerAmount)
	headLight.energy = flicker


func _on_trash_pickup_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("Trash"):
		SetState(STATE.EAT)
		area.get_parent().queue_free()
		
		await get_tree().create_timer(2).timeout
		SetState(STATE.WANDERING)

func _on_de_agro_range_area_entered(_area: Area2D) -> void:
	SetState(STATE.CHASE)
