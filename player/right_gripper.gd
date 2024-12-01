extends Area3D

class_name RightGripper

@export var left_gripper: LeftGripper 
@export var gripped_prev_root: Node = null
@export var gripped: PhysicsBody3D = null

func _on_gus_toggle_grip_right_hand() -> void:
	if gripped != null:
		if gripped is Weapon:
			gripped.on_released()
			
		gripped.reparent(gripped_prev_root)
		gripped = null
		return

	if has_overlapping_bodies() == false:
		return
	
	var overlap_bodies = get_overlapping_bodies()
	var pickme: Node3D = null
	for body in overlap_bodies: 
		if body == left_gripper.gripped:
			continue
			
		pickme = body
		
	if pickme == null:
		return 
		
	gripped_prev_root = pickme.get_parent_node_3d()
	if gripped_prev_root == null:
		gripped_prev_root = get_tree().current_scene
	
	pickme.reparent(self, true)
	gripped = pickme
	
	if gripped is Weapon:
		gripped.on_held()
