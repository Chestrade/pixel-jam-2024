extends CharacterBody2D
@export_category("Movement")
@export var speed = 300
@export var nav_agent : NavigationAgent2D
@export var markers : Array[Marker2D] = []

@export_category("Health")
@export var  healthColors : Array[Color] = []
@export_range(0, 100) var health

@onready var headLight : PointLight2D = $PointLight2D
var currentMarkerIndex = -1
var isReachingTarget : bool = false

var target_node = null

enum STATE {WANDERING, CHASE}
var currentState : STATE

func _ready() -> void:
	health = 100
	SetState(STATE.WANDERING)
	nav_agent.path_desired_distance = 4
	nav_agent.target_desired_distance = 4

func _process(delta: float) -> void:
	StateUpdate()
	HealthLightColor()

func HealthLightColor() -> void:
	if health >= 75:
		headLight.set_color(healthColors[0]) 
	elif health <75 and health >= 50:
		headLight.set_color(healthColors[1])
	elif health <50 and health >=25:
		headLight.set_color(healthColors[2]) 
	elif health <25:
		headLight.set_color(healthColors[3]) 

func StateUpdate() -> void:
	match currentState:
		STATE.WANDERING:
			if isReachingTarget:
				if nav_agent.is_navigation_finished():
					isReachingTarget = false
					currentMarkerIndex = (currentMarkerIndex + 1) % markers.size()
					nav_agent.target_position = markers[currentMarkerIndex].global_position
					
			else:
				if nav_agent.is_navigation_finished():
					isReachingTarget = true
					nav_agent.target_position = markers[currentMarkerIndex].global_position
					
		STATE.CHASE:
			nav_agent.target_position = target_node.global_position
	
	if nav_agent.is_navigation_finished(): #if the nav agent reached its target
		return
	var axis : Vector2 = to_local(nav_agent.get_next_path_position()).normalized()
	velocity = axis * speed
	move_and_slide()

func SetState(newState : STATE) -> void:
	currentState = newState

func recalc_path() -> void:
	if target_node and currentState == STATE.CHASE:
		nav_agent.target_position = target_node.global_position
	elif currentState == STATE.WANDERING:
		nav_agent.target_position = markers[currentMarkerIndex].global_position

func _on_timer_timeout() -> void:
	recalc_path()

func _on_area_2d_area_entered(area: Area2D) -> void:
	SetState(STATE.CHASE)
	target_node = area.owner

func _on_area_2d_area_exited(area: Area2D) -> void:
	if area.owner == target_node:
		target_node = null
	SetState(STATE.WANDERING)
