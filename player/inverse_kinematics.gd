extends SkeletonIK3D

@export var active_right_hand_reach: bool = false

func _on_gus_toggle_right_hand_reach() -> void:
	active_right_hand_reach = !active_right_hand_reach
	if active_right_hand_reach:
		start()
	else:
		stop()
