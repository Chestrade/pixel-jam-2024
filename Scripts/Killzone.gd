extends Area2D

@onready var player_body : Node = get_tree().get_nodes_in_group("Player")[0]

func _physics_process(_delta: float) -> void:
	if overlaps_body(player_body):
		player_body.takeDamage(25)
