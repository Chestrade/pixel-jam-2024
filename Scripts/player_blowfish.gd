extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -300.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if (Input.get_vector("swim_left","swim_right","swim_up","swim_down"))==Vector2.ZERO:
		velocity.y = 0

	# Handle jump.
	if Input.is_action_just_pressed("swim_up"):
		velocity.y = JUMP_VELOCITY
	elif Input.is_action_just_pressed("swim_down"):
		velocity.y = -JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("swim_left", "swim_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
