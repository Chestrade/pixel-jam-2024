extends CharacterBody2D

@export var patrolSpeed : float = 300.0
@export var chaseSpeed : float = 350.0

@onready var nav : NavigationAgent2D = $NavigationAgent2D
@onready var animationPlayer : AnimationPlayer = $AnglerFishAnimationPlayer

enum AnglerState {WANDERING, ALERT, CHASE, EAT}
var currentState : AnglerState

func _ready() -> void:
	setState(AnglerState.WANDERING)

func _physics_process(delta: float) -> void:
	UpdateState(delta)

func setState(newState : AnglerState) -> void:
	if(currentState == newState):
		return
	
	ExitState()
	currentState = newState
	EnterState()

func EnterState() -> void: #What happens when the angler fish enters a state
	match currentState:
		AnglerState.WANDERING:
			animationPlayer.play("wandering")
		AnglerState.ALERT:
			animationPlayer.play("alert")
		AnglerState.CHASE:
			animationPlayer.play("chase")
		AnglerState.EAT:
			animationPlayer.play("eat")

func ExitState() -> void: # What happens when the anglerfish exits a state
	match currentState:
		AnglerState.WANDERING:
			pass
		AnglerState.ALERT:
			pass
		AnglerState.CHASE:
			pass
		AnglerState.EAT:
			pass
		

func UpdateState(delta : float) -> void: #Manages state behaviour
	match currentState:
		AnglerState.WANDERING: #Wandering State behavior
			pass
		AnglerState.ALERT: # Alert State Behaviour
			pass
		AnglerState.CHASE: # Chase State Behaviour
			pass
		AnglerState.EAT: # Eat State Behaviour
			pass
	



