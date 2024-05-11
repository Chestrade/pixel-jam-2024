extends CharacterBody2D

@export var speed = 5000
@export var nav_agent : NavigationAgent2D

@export var markers : Array[Marker2D] = []
var currentMarkerIndex = -1
var isReachingTarget : bool = false

var target_node = null
var home_pos = Vector2.ZERO

enum STATE {WANDERING, CHASE}
var currentState : STATE

func _ready() -> void:
	SetState(STATE.WANDERING)
	home_pos = self.global_position
	nav_agent.path_desired_distance = 4
	nav_agent.target_desired_distance = 4

func _physics_process(delta: float) -> void:
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
	velocity = axis * speed * delta
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
