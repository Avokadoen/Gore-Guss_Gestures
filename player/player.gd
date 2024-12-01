extends CharacterBody3D

signal toggle_right_hand_reach(character: CharacterBody3D, skel: Skeleton3D, head_id: int, turn_rate: float, look_x_degree_limit_min: float, look_x_degree_limit_max: float)
signal toggle_grip_right_hand
signal toggle_left_hand_reach(character: CharacterBody3D, skel: Skeleton3D, head_id: int, turn_rate: float, look_x_degree_limit_min: float, look_x_degree_limit_max: float)
signal toggle_grip_left_hand

# TODO: 
# - interaction handling
# 	- sharp weapon: able to freely move a sword using mouse
# 		- slicing on high velocity impact, deformation on low vel impact: https://github.com/PiCode9560/Godot-4-Concave-Mesh-Slicer/tree/main
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

@export var relative_crouch_height: float = 0.4

var is_crouch: bool = false
var capsule_original_height: float = 0
var player_capsule: CollisionShape3D

var is_right_hand_reach_active: bool = false
var is_left_hand_reach_active: bool = false

var gus_skeleton: Skeleton3D
var gus_head_id: int

var is_dead: bool = false

var turn_angle: Vector2 = Vector2.ZERO
var target_velocity: Vector3 = Vector3.ZERO

func _ready() -> void:
	gus_skeleton = get_node("Gus_01/Main_Rig/Skeleton3D")
	gus_head_id = gus_skeleton.find_bone(player_skeleton_head_name)

	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	# ensure player camera is used as active camera
	var main_camera: Camera3D = get_node("Gus_01/Main_Rig/Skeleton3D/HeadAttachment/EyeCamera")
	main_camera.make_current()
	
	player_capsule = get_node("PlayerCapsule")


func _process(_delta: float) -> void:
	# DEBUG: exit on presumably "esc" 
	if Input.is_action_just_pressed("debug_exit"):
		get_tree().quit()
		return
		
	if is_dead:
		return
	
	if !is_right_hand_reach_active and !is_left_hand_reach_active:
		CharacterUtils.turnAround(self, gus_skeleton, gus_head_id, turn_angle, turn_rate, look_x_degree_limit_min, look_x_degree_limit_max)
		
	turn_angle = Vector2.ZERO
		
	# handle crouch 
	if Input.is_action_just_pressed("crouch"):
		is_crouch = !is_crouch
		var capsule_res = player_capsule.shape as CapsuleShape3D
		if is_crouch:
			capsule_original_height = capsule_res.height
			capsule_res.height = capsule_original_height * relative_crouch_height
		else:
			capsule_res.height = capsule_original_height
			position.y += (capsule_original_height - capsule_res.height) * 0.5
		
	if Input.is_action_just_pressed("interactive_action_right_hand"):
		toggle_right_hand_reach.emit(self, gus_skeleton, gus_head_id, turn_rate, look_x_degree_limit_min, look_x_degree_limit_max)
		is_right_hand_reach_active = !is_right_hand_reach_active
	if Input.is_action_just_pressed("interactive_action_left_hand"):
		toggle_left_hand_reach.emit(self, gus_skeleton, gus_head_id, turn_rate, look_x_degree_limit_min, look_x_degree_limit_max)
		is_left_hand_reach_active = !is_left_hand_reach_active
	if Input.is_action_just_pressed("toogle_grip_right_hand"):
		toggle_grip_right_hand.emit()
	if Input.is_action_just_pressed("toogle_grip_left_hand"):
		toggle_grip_left_hand.emit()
	

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
	if !is_right_hand_reach_active and !is_left_hand_reach_active and event is InputEventMouseMotion:
		turn_angle += event.relative


func _on_gus_01_died() -> void:
	get_node("PlayerCapsule").disabled = true
	is_dead = true
