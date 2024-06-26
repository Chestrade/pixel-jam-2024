extends CharacterBody2D

class_name Player

signal on_spikes_retracted()

@export var SWIM_SPEED: float = 300.0
@export var DASH_SPEED: float = 1000.0
@export var inertia: float = 0.95
@export var chonkiness: float = 1

var screen_size
var direction: Vector2
var is_move_input_received: bool = true
var is_sinking: bool = false
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

var health : int

# Audio stuff
@onready var splashSounds : AudioStreamPlayer2D = $"Node/Splash Sounds"
@onready var inflateSounds : AudioStreamPlayer = $"Node/Inflate"
@onready var _animated_sprite = $AnimatedSprite2D

func _ready() -> void:
	screen_size = get_viewport_rect().size
	health = 100
	$AnimatedSprite2D.animation = "default"
	_animated_sprite.play("default")

func _physics_process(delta: float) -> void:
	get_input()
	
	# Dash on player input
	if Input.is_action_pressed("dash") and $DashCooldown.is_stopped():
		$DashCooldown.start()
		$AnimatedSprite2D.scale.x = 1.2
		$AnimatedSprite2D.scale.y = 0.8
		splashSounds.play()
		if $AnimatedSprite2D.is_flipped_h():
			velocity.x = -DASH_SPEED
		else:
			velocity.x = DASH_SPEED
	# Decrease velocity when player is dashing
	elif velocity.length() > SWIM_SPEED:
		velocity *= inertia
	# Walk if not dashing
	elif velocity.length() <= SWIM_SPEED:
		$AnimatedSprite2D.scale.x = 1
		$AnimatedSprite2D.scale.y = 1
	
	# Slowly decrease velocity
	if !is_move_input_received:
		velocity *= inertia
	elif velocity.length() <= SWIM_SPEED:
		velocity = SWIM_SPEED * chonkiness * direction.normalized()
	
	if is_sinking:
		velocity.y = gravity * delta
	
	# Flip sprite according to direction of movement
	if velocity.x != 0:
		$AnimatedSprite2D.flip_h = velocity.x < 0
	
	move_and_slide()

func get_input():
	direction = Vector2.ZERO
	# Calculate movement vector
	if Input.is_action_pressed("swim_right"):		direction.x = 1
	if Input.is_action_pressed("swim_left"):
		direction.x = -1
	if Input.is_action_pressed("swim_down"):
		direction.y = 1
	if Input.is_action_pressed("swim_up"):
		direction.y = -1
	
	# If player is not moving
	if !Input.is_action_pressed("swim_up") and \
	   !Input.is_action_pressed("swim_down") and \
	   !Input.is_action_pressed("swim_left") and \
	   !Input.is_action_pressed("swim_right"):
		is_move_input_received = false
		
		if $SinkTimer.is_stopped():
			$SinkTimer.start()
	else:
		$SinkTimer.stop()
		is_sinking = false
		is_move_input_received = true
	
	# Inflate on player input
	if Input.is_action_pressed("inflate") and $AnimatedSprite2D.animation == "default" and \
	   $InflationCooldown.is_stopped():
		$AnimatedSprite2D.animation = "chonked"
		_animated_sprite.play("chonked")
		$InflationCooldown.start()
		chonkiness = 0.5
		inflateSounds.play()
	elif Input.is_action_pressed("inflate") and $InflationCooldown.is_stopped():
		$AnimatedSprite2D.animation = "default"
		$InflationCooldown.start()
		chonkiness = 1
		on_spikes_retracted.emit()

func takeDamage(damage : int) -> void:
	if $InvincibilityCooldown.is_stopped():
		health -= damage
		$InvincibilityCooldown.start()
	# print("Player health = " + str(health))
	if health <= 0:
		health = 0
		get_tree().change_scene_to_file("res://Scenes/game_over_scene.tscn")

func _on_sink_timer_timeout() -> void:
	is_sinking = true
	


