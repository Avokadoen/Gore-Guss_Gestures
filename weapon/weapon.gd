extends RigidBody3D

class_name Weapon

# Which relative position the weapon should have when held
@export var on_held_position = Vector3.ZERO

# Which relative rotation the weapon should have when held
@export var on_held_euler_rotation = Vector3.ZERO

@export var on_held_disable_colliders: Array[CollisionShape3D]

func on_held():
	position = on_held_position
	rotation_degrees = on_held_euler_rotation
	
	for collider in on_held_disable_colliders:
		collider.disabled = true
	
func on_released():
	for collider in on_held_disable_colliders:
		collider.disabled = false
	
