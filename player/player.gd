extends CharacterBody3D

# How fast the player moves in meters per second.
@export var move_speed: float = 100

# How hight the player can jump
@export var jump_height: float = 5

# How fast the player turns
@export var turn_rate: float = 0.01

# Changes how fast player can move while in air relative to normal move speed
@export var fly_speed_multiplier: float = 0.5

# Changes how far the player can look up and down
@export var look_x_degree_limit: float = 90

# Changes how fast player can move while in air
@export var camera_node: Camera3D

var orientation: Transform3D = Transform3D()

var turn_angle: Vector2 = Vector2.ZERO

var target_velocity: Vector3 = Vector3.ZERO

func _ready() -> void:
	orientation = global_transform
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _process(_delta: float) -> void:
		# handle turning 
	if turn_angle != Vector2.ZERO:
		turn_angle *= turn_rate
		rotate_y(-turn_angle.x)
		
		var x_rotation_limit = deg_to_rad(look_x_degree_limit)
		var is_higher_than_min_limit = camera_node.rotation.x >= -x_rotation_limit 
		var is_lower_than_max_limit = camera_node.rotation.x <= x_rotation_limit
		if (is_higher_than_min_limit and is_lower_than_max_limit):
			var camera_rotation = camera_node.get_rotation()
			camera_rotation.x = clamp(camera_rotation.x - turn_angle.y, -x_rotation_limit + 0.001, x_rotation_limit - 0.001)
			camera_node.set_rotation(camera_rotation)
		
		turn_angle = Vector2.ZERO
	
	# DEBUG: exit on presumably "esc" 
	if Input.is_action_just_pressed("debug_exit"):
		get_tree().quit()

func _physics_process(delta) -> void:
	# We create a local variable to store the input direction.
	var move_direction = Vector3.ZERO
	
	var forward_vector = -global_transform.basis.z
	var right_vector = global_transform.basis.x
	
	# We check for each move input and update the direction accordingly.
	if Input.is_action_pressed("forward"):
		move_direction += forward_vector
	if Input.is_action_pressed("backward"):
		move_direction -= forward_vector
	if Input.is_action_pressed("left"):
		move_direction -= right_vector
	if Input.is_action_pressed("right"):
		move_direction += right_vector

	# If we had some input, apply it to the velocity
	if move_direction != Vector3.ZERO:
		move_direction = move_direction.normalized()
	
	# Store any fall/jump velocity from prevous frame
	var tmp_y_target_velocity = velocity.y
	
	# Apply any walk input, account for being in the air
	var fly_speed_modifier: float = 1.0 if is_on_floor() else fly_speed_multiplier
	target_velocity = move_direction * move_speed * fly_speed_modifier;
	
	# Apply previus fall/jump velocity (Gravity + ground collision smooths this)
	target_velocity.y = tmp_y_target_velocity
	
	# Handle jump
	if Input.is_action_pressed("jump") and is_on_floor():
		target_velocity.y += jump_height
	
	velocity = target_velocity
	
	# Apply gravity
	velocity -= Vector3.DOWN * get_gravity() * delta
	
	move_and_slide()


func _input(event):
	if event is InputEventMouseMotion:
		turn_angle += event.relative
