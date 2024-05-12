extends CharacterBody2D

## The speed at which the projectile will move.
@export var speed = 200
var dir : float
var spawnPosition : Vector2
var spawnRotation : float

func _ready() -> void:
	global_position = spawnPosition
	global_rotation = spawnRotation

func _physics_process(delta: float) -> void:
	velocity = Vector2(0, -speed).rotated(dir)
	move_and_slide()
