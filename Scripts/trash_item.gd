extends RigidBody2D

signal on_trash_spikes_collision

@onready var player_ref : Node = get_tree().get_nodes_in_group("Player")[0]

var screen_size
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_trash_on_spikes : bool = false
var relative_position : Vector2 = Vector2.ZERO
var area_parent : Node
var area_parent_anim : Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_viewport_rect().size
	player_ref.connect("on_spikes_retracted", _on_player_on_spikes_retracted)

func _physics_process(delta) -> void:
	if is_trash_on_spikes and area_parent.is_in_group("Player"):
		# Ensure that trash flips when player is flipped
		if area_parent_anim.is_flipped_h():
			position = area_parent.position + relative_position
			position.x -= 2 * relative_position.x
		else:
			position = area_parent.position + relative_position
	else:
		position.y += gravity * delta
	
	# Prevent trash from exiting screen
	position = position.clamp(Vector2.ZERO, screen_size)

func _on_pickup_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("Player"):
		area_parent = area.get_parent()
		area_parent_anim = get_node(str(area_parent.get_path()) + "/AnimatedSprite2D")
	
	# If trash collided with player
	if area.is_in_group("Player") and area_parent_anim.animation == "chonked" \
	   and !is_trash_on_spikes:
		on_trash_spikes_collision.emit()
		is_trash_on_spikes = true
		$CollisionShape2D.set_deferred("disabled", true)
		relative_position = position - area_parent.position


func _on_player_on_spikes_retracted() -> void:
	is_trash_on_spikes = false
	$CollisionShape2D.set_deferred("disabled", false)
