extends Node2D

## The parent node of the bullets that this object will instantiate
@export var main : Node
@export var defaultLookAtPosition : Node2D
@export var projectileSpawnPosition : Marker2D

@onready var projectile = load("res://Characters/projectile.tscn")
@onready var shoot_sfx : AudioStreamPlayer2D = $"Audio/Plant Spit SFX"
@onready var grunt_sfx : AudioStreamPlayer2D = $"Audio/Plant Grunt"

var ROT_SPEED : float = 0.1
var defaultRotation : float
var target : Node2D
var target_next_position : Vector2

var playerDetected : bool = false

func _ready() -> void:
	defaultRotation = rotation
	target = defaultLookAtPosition

func _physics_process(_delta: float) -> void:
	if target == null:
		return
	else:
		target_next_position = target.position + 0.5 * target.velocity
		rotation = lerp_angle(rotation, (target_next_position - position).angle() + PI/2, ROT_SPEED)
		rotation = clamp(rotation,-PI/2 + defaultRotation, PI/2 + defaultRotation)

func Shoot() -> void:
	var instance = projectile.instantiate()
	instance.look_at(target.position)
	instance.spawnPosition = global_position + Vector2.UP.rotated(rotation) * 80
	instance.dir = rotation
	get_parent().add_child.call_deferred(instance)
	shoot_sfx.play() # plays spitting sound

func _on_player_detection_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("Player"):
		playerDetected = true
		target = area.owner
		grunt_sfx.play()

func _on_player_detection_area_area_exited(area: Area2D) -> void:
	if area.is_in_group("Player"):
		playerDetected = false
		target = defaultLookAtPosition
	
func _on_cooldown_timeout() -> void:
	if playerDetected:
		Shoot()
