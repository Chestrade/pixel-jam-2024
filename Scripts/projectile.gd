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


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Detection Area"):
		print("Projectile detected body with group : Detection Area")
		return
	else:
		print("Projectile destroyed on impact" + body.name)
		queue_free()


func _on_life_timeout() -> void:
	queue_free()
	print("Projectile kaput.")
