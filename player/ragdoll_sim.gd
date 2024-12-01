extends PhysicalBoneSimulator3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	physical_bones_start_simulation()
	influence = 0

func _on_gus_died() -> void:
	influence = 1
