extends Area3D

@export var gripped_prev_root: Node = null
@export var gripped: RigidBody3D = null


func _on_gus_toggle_grip_right_hand() -> void:
	if gripped != null:
		if gripped is Weapon:
			gripped.on_released()
		
		gripped.freeze = false
		gripped.reparent(gripped_prev_root)
		return

	if has_overlapping_bodies() == false:
		return
		
	var pickme = get_overlapping_bodies()[0]
	gripped_prev_root = pickme.get_parent_node_3d()
	if gripped_prev_root == null:
		gripped_prev_root = get_tree().current_scene
		
	pickme.reparent(self, true)
	gripped = pickme
	
	if gripped is Weapon:
		gripped.on_held()
	
	gripped.freeze = true
	
