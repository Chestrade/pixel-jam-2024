extends Node2D

## The parent node of the bullets that this object will instantiate
@export var main : Node

@export var defaultLookAtPosition : Node
@export var projectileSpawnPosition : Marker2D

@onready var projectile = load("res://Characters/projectile.tscn")

var target

var playerDetected : bool = false

func _ready() -> void:
	target = defaultLookAtPosition

func _physics_process(_delta: float) -> void:
	if target == null:
		return
	else:
		look_at(target.position)
		rotate(PI/2)

func Shoot() -> void:
	var instance = projectile.instantiate()
	instance.look_at(target.position)
	instance.spawnPosition = global_position
	instance.dir = rotation
	get_parent().add_child.call_deferred(instance)

func _on_player_detection_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("Player"):
		playerDetected = true
		target = area.owner

func _on_player_detection_area_area_exited(area: Area2D) -> void:
	if area.is_in_group("Player"):
		playerDetected = false
		target = defaultLookAtPosition
	
func _on_cooldown_timeout() -> void:
	if playerDetected:
		Shoot()