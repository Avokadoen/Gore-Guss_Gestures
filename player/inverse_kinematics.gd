extends SkeletonIK3D

@export var ik_target_node: Node3D

# How far the character can right with any arm, it's half as the length is only in one direction
@export var ik_reach_half_bound_min: Vector2 = Vector2(0.008, 0.0035)

@export var active_right_hand_reach: bool = false

var target_node_origin: Vector3

var m_char: CharacterBody3D
var m_skel: Skeleton3D
var m_head_id: int
var m_turn_angle: Vector2
var m_turn_rate: float
var m_look_x_degree_limit_min: float
var m_look_x_degree_limit_max: float

func _ready() -> void:
	target_node_origin = ik_target_node.position
	
func _physics_process(_delta: float) -> void:
	if !active_right_hand_reach:
		return
	
	ik_target_node.position += Vector3(-m_turn_angle.x * m_turn_rate * 0.01, 0, -m_turn_angle.y * m_turn_rate * 0.01)
	var min_val = Vector3(-ik_reach_half_bound_min.x, 0, -ik_reach_half_bound_min.y)
	var max_val = Vector3(ik_reach_half_bound_min.x, 0, ik_reach_half_bound_min.y)
	var node_pos = ik_target_node.position.clamp(min_val, max_val);
	if node_pos != ik_target_node.position:
		CharacterUtils.turnAround(m_char, m_skel, m_head_id, m_turn_angle, m_turn_rate, m_look_x_degree_limit_min, m_look_x_degree_limit_max)
		
	ik_target_node.position = node_pos
	m_turn_angle = Vector2.ZERO

func _on_gus_toggle_right_hand_reach(character: CharacterBody3D, skel: Skeleton3D, head_id: int, turn_rate: float, look_x_degree_limit_min: float, look_x_degree_limit_max: float) -> void:
	active_right_hand_reach = !active_right_hand_reach
	if active_right_hand_reach:
		m_char = character
		m_skel = skel
		m_head_id = head_id
		m_turn_rate = turn_rate
		m_look_x_degree_limit_min = look_x_degree_limit_min
		m_look_x_degree_limit_max = look_x_degree_limit_max
		start()
	else:
		stop()

func _input(event):
	if active_right_hand_reach and event is InputEventMouseMotion:
		m_turn_angle += event.relative
