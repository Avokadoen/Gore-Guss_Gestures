extends Node3D

signal died

@export var max_health: float = 100

@export var bone_simulation: PhysicalBoneSimulator3D

var health: float = 0

func _ready() -> void:
	health = max_health

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	
	# If living is dead ( :) )
	if health <= 0:
		if bone_simulation.is_active() == false:
			bone_simulation.set_active(true)
			died.emit()
