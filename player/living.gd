extends Node3D

signal died
signal toggle_right_hand_reach(character: CharacterBody3D, skel: Skeleton3D, head_id: int, turn_rate: float, look_x_degree_limit_min: float, look_x_degree_limit_max: float)
signal toggle_grip_right_hand
signal toggle_left_hand_reach(character: CharacterBody3D, skel: Skeleton3D, head_id: int, turn_rate: float, look_x_degree_limit_min: float, look_x_degree_limit_max: float)
signal toggle_grip_left_hand

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


func _on_player_toggle_right_hand_reach(character: CharacterBody3D, skel: Skeleton3D, head_id: int, turn_rate: float, look_x_degree_limit_min: float, look_x_degree_limit_max: float) -> void:
	toggle_right_hand_reach.emit(character, skel, head_id, turn_rate, look_x_degree_limit_min, look_x_degree_limit_max)

func _on_player_toggle_left_hand_reach(character: CharacterBody3D, skel: Skeleton3D, head_id: int, turn_rate: float, look_x_degree_limit_min: float, look_x_degree_limit_max: float) -> void:
	toggle_left_hand_reach.emit(character, skel, head_id, turn_rate, look_x_degree_limit_min, look_x_degree_limit_max)

func _on_player_toggle_grip_right_hand() -> void:
	toggle_grip_right_hand.emit()

func _on_player_toggle_grip_left_hand() -> void:
	toggle_grip_left_hand.emit()
