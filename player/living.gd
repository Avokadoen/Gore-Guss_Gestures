extends Node3D

signal died
signal toggle_right_hand_reach

@export var max_health: float = 100

@export var bone_simulation: PhysicalBoneSimulator3D

var health: float = 0
var is_alive: bool = true

func _ready() -> void:
	health = max_health

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	
	is_alive = is_alive and health > 0
	
	if is_alive == false:
		bone_simulation.set_active(true)
		died.emit()


func _on_player_toggle_right_hand_reach() -> void:
	toggle_right_hand_reach.emit()
