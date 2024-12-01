extends Node

class_name CharacterUtils

static func turnAround(character: CharacterBody3D, skel: Skeleton3D, head_id: int, turn_angle: Vector2, turn_rate: float, look_x_degree_limit_min: float, look_x_degree_limit_max: float):
	# handle turning 
	if turn_angle == Vector2.ZERO:
		return

	turn_angle *= turn_rate
	character.rotate_y(-turn_angle.x)
	
	var head_euler_rotation: Vector3 = skel.get_bone_pose_rotation(head_id).normalized().get_euler(EULER_ORDER_YXZ)
	var x_rotation_limit_min: float = deg_to_rad(look_x_degree_limit_min)
	var x_rotation_limit_max: float = deg_to_rad(look_x_degree_limit_max)
	
	var is_higher_than_min_limit: bool =  head_euler_rotation.x >= x_rotation_limit_min 
	var is_lower_than_max_limit: bool = head_euler_rotation.x <= x_rotation_limit_max
	if (is_higher_than_min_limit and is_lower_than_max_limit):
		head_euler_rotation.x = clamp(head_euler_rotation.x + turn_angle.y, x_rotation_limit_min + 0.1, x_rotation_limit_max - 0.1)
		skel.set_bone_pose_rotation(head_id, Quaternion.from_euler(head_euler_rotation))
	
	turn_angle = Vector2.ZERO
