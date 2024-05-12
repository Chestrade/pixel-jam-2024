extends CharacterBody2D


@export var SWIM_SPEED: float = 300.0
@export var DASH_SPEED: float = 1000.0
@export var inertia: float = 0.95
@export var chonkiness: float = 1

var screen_size
var direction: Vector2
var is_move_input_received: bool = true
var is_sinking: bool = false
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready() -> void:
	screen_size = get_viewport_rect().size

func _physics_process(delta: float) -> void:
	get_input()
	
	# Dash on player input
	if Input.is_action_pressed("dash") and $DashCooldown.is_stopped():
		$DashCooldown.start()
		$AnimatedSprite2D.scale.x = 1.2
		$AnimatedSprite2D.scale.y = 0.8
		if $AnimatedSprite2D.is_flipped_h():
			velocity.x = -DASH_SPEED
		else:
			velocity.x = DASH_SPEED
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
	
	# Inflate on player input
	if Input.is_action_pressed("inflate") and $AnimatedSprite2D.animation == "default" and \
	   $InflationCooldown.is_stopped():
		$AnimatedSprite2D.animation = "chonked"
		$InflationCooldown.start()
		chonkiness = 0.5
	elif Input.is_action_pressed("inflate") and $InflationCooldown.is_stopped():
		$AnimatedSprite2D.animation = "default"
		$InflationCooldown.start()
		chonkiness = 1

func _on_sink_timer_timeout() -> void:
	is_sinking = true
