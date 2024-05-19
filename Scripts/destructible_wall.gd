extends StaticBody2D

var health : int = 100
var area_name : Area2D = null

func _ready() -> void:
	pass


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


func _on_damage_area_area_exited(area: Area2D) -> void:
	if area == area_name:
		area_name = null
