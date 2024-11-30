extends CharacterBody3D

# TODO: 
# - ragdoll (waiting on model): https://docs.godotengine.org/en/stable/tutorials/physics/ragdoll_system.html
# - interaction handling
# 	- sharp weapon: able to freely move a sword using mouse
# 		- slicing on high velocity impact, deformation on low vel impact: https://github.com/PiCode9560/Godot-4-Concave-Mesh-Slicer/tree/main
# 	- able to drop any held item and pick up new item
# 	- can control both hands (left and right mouse click)
# 	- blunt weapon: 
# 	- magic?
# 	- env (doors, chests)

# How fast the player moves in meters per second.
@export var move_speed: float = 100

# How hight the player can jump
@export var jump_height: float = 5

# How fast the player turns
@export var turn_rate: float = 0.01

# Changes how fast player can move while in air relative to normal move speed
@export var fly_speed_multiplier: float = 0.5

# Changes how far the player can look up and down
@export var look_x_degree_limit_min: float = -90
@export var look_x_degree_limit_max: float = 75

# Name of the head bone of the player model skeleton
@export var player_skeleton_head_name = "Head.001"

var gus_skeleton: Skeleton3D
var gus_head_id: int

var is_dead: bool = false

var orientation: Transform3D = Transform3D()
var turn_angle: Vector2 = Vector2.ZERO
var target_velocity: Vector3 = Vector3.ZERO

func _ready() -> void:
	gus_skeleton = get_node("Gus_01/Main_Rig/Skeleton3D")
	gus_head_id = gus_skeleton.find_bone(player_skeleton_head_name)

	orientation = global_transform
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	# ensure player camera is used as active camera
	var main_camera: Camera3D = get_node("Gus_01/Main_Rig/Skeleton3D/BoneAttachment3D/EyeCamera")
	main_camera.make_current()


func _process(_delta: float) -> void:
	# DEBUG: exit on presumably "esc" 
	if Input.is_action_just_pressed("debug_exit"):
		get_tree().quit()
		return
		
	if is_dead:
		return
	
	# handle turning 
	if turn_angle != Vector2.ZERO:
		turn_angle *= turn_rate
		rotate_y(-turn_angle.x)
		
		var head_euler_rotation: Vector3 = gus_skeleton.get_bone_pose_rotation(gus_head_id).normalized().get_euler(EULER_ORDER_YXZ)
		var x_rotation_limit_min: float = deg_to_rad(look_x_degree_limit_min)
		var x_rotation_limit_max: float = deg_to_rad(look_x_degree_limit_max)
		
		var is_higher_than_min_limit: bool =  head_euler_rotation.x >= x_rotation_limit_min 
		var is_lower_than_max_limit: bool = head_euler_rotation.x <= x_rotation_limit_max
		if (is_higher_than_min_limit and is_lower_than_max_limit):
			head_euler_rotation.x = clamp(head_euler_rotation.x + turn_angle.y, x_rotation_limit_min + 0.1, x_rotation_limit_max - 0.1)
			gus_skeleton.set_bone_pose_rotation(gus_head_id, Quaternion.from_euler(head_euler_rotation))
		
		turn_angle = Vector2.ZERO
	

func _physics_process(delta) -> void:
	if is_dead:
		return
	
	# We create a local variable to store the input direction.
	var move_direction = Vector3.ZERO
	
	var forward_vector = global_transform.basis.z
	var right_vector = -global_transform.basis.x
	
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
	
	# Apply all input so far for this frame
	velocity = target_velocity
	
	# Apply gravity
	velocity -= Vector3.DOWN * get_gravity() * delta
	
	move_and_slide()


func _input(event):
	if event is InputEventMouseMotion:
		turn_angle += event.relative


func _on_gus_01_died() -> void:
	get_node("PlayerCapsule").disabled = true
	is_dead = true
