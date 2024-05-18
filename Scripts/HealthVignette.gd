extends ColorRect

@export var player : CharacterBody2D
var speed : float = 0.3
var playerHealth : float
var shader_value : float = 0.0

func _ready() -> void:
	shader_value = 0.0

func _process(delta: float) -> void:
	playerHealth = float(player.health)
	var invertedPlayerHealth : float = 100 - playerHealth
	shader_value = lerp(shader_value, invertedPlayerHealth/100, speed)
	shader_value = clamp(shader_value, 0.0, 1)
	
	var redness = 1.0 - playerHealth /100.0
	var vignetteColor = Color(redness, 0.0, 0.0, 1.0)
	
	material.set_shader_parameter("vignette_intensity", shader_value)
	material.set_shader_parameter("vignette_rgb", vignetteColor)
