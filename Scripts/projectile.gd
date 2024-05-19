extends CharacterBody2D

## The speed at which the projectile will move.
@export var speed = 200
var dir : float
var spawnPosition : Vector2
var spawnRotation : float

@onready var explosion_particules : GPUParticles2D = $"Explosion particules"
@onready var audio_player : AudioStreamPlayer2D = $"Impact SFX"
func _ready() -> void:
	global_position = spawnPosition
	global_rotation = spawnRotation

func _physics_process(_delta: float) -> void:
	velocity = Vector2(0, -speed).rotated(dir)
	move_and_slide()

func emit_particules() -> void: # used to emit particules at the end of the node's life
	explosion_particules.set_emitting(true)
	audio_player.play()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Detection Area"):
		return
	else:
		if body.name == "Player":
			body.takeDamage(25)
		emit_particules()
		queue_free()

func _on_life_timeout() -> void:
	emit_particules()
	queue_free()
	
