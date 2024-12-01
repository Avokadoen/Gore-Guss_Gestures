extends RigidBody3D

class_name Weapon

# Which node will be the sliced rigid body parent
@export var sliced_dest: Node3D

# Which relative position the weapon should have when held
@export var on_held_position = Vector3.ZERO

# Which relative rotation the weapon should have when held
@export var on_held_euler_rotation = Vector3.ZERO

@export var on_held_disable_colliders: Array[CollisionShape3D]

var is_held: bool = false

func _ready() -> void:
	get_node("MeshSlicer").sliced_dest = sliced_dest
	
func _physics_process(delta: float) -> void:
	if is_held:
		position = on_held_position
		rotation_degrees = on_held_euler_rotation

func on_held():
	gravity_scale = 0
	is_held = true
	for collider in on_held_disable_colliders:
		collider.disabled = true
	
func on_released():
	gravity_scale = 1
	is_held = false
	for collider in on_held_disable_colliders:
		collider.disabled = false
	
