extends CharacterBody2D


@export var inertia: float = 0.95
const SPEED = 300.0

var screen_size
var direction: Vector2
var is_move_input_received: bool = true
var is_sinking: bool = false
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready() -> void:
	screen_size = get_viewport_rect().size

func _physics_process(delta: float) -> void:
	get_input()
	
	# If no movement input, slowly decrease velocity
	if !is_move_input_received:
		velocity = velocity * inertia
	else:
		velocity = direction.normalized() * SPEED
	
	if is_sinking:
		velocity.y = gravity * delta
	
	# Flip sprite according to direction of movement
	if velocity.x != 0:
		$AnimatedSprite2D.flip_h = velocity.x < 0
	
	# Prevent player from leaving screen
	position = position.clamp(Vector2.ZERO, screen_size)
	
	move_and_slide()

func get_input():
	direction = Vector2.ZERO
	# Calculate movement vector
	if Input.is_action_pressed("swim_right"):
		direction.x = 1
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

func _on_sink_timer_timeout() -> void:
	is_sinking = true
