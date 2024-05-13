extends CharacterBody2D

## The speed at which the projectile will move.
@export var speed = 200
var dir : float
var spawnPosition : Vector2
var spawnRotation : float

func _ready() -> void:
	global_position = spawnPosition
	global_rotation = spawnRotation

func _physics_process(_delta: float) -> void:
	velocity = Vector2(0, -speed).rotated(dir)
	move_and_slide()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Detection Area"):
		return
	else:
		if body.name == "Player":
			body.takeDamage(25)
		# print(body.name, " was hit")
		queue_free()

func _on_life_timeout() -> void:
	queue_free()