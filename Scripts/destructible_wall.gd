extends StaticBody2D

var health : int = 100
var area_name : Area2D = null

@onready var _animated_sprite = $AnimatedSprite2D

func _ready() -> void:
	pass
	_animated_sprite.stop


func _process(_delta: float) -> void:
	if area_name != null:
		if $DamageArea.overlaps_area(area_name) and $InvincibilityCooldown.is_stopped():
			health -= 35
			$InvincibilityCooldown.start()
		if health <= 0:
			queue_free()


func _on_damage_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("Trash"):
		area_name = area
		_animated_sprite.play("default")


func _on_damage_area_area_exited(area: Area2D) -> void:
	if area == area_name:
		area_name = null
