# Source: https://github.com/PiCode9560/Godot-4-Concave-Mesh-Slicer/blob/main/Godot%204%20Concave%20Mesh%20Slicer/addons/concave%20mesh%20slicer/ConcaveMeshSlicer.gd
# LICENSE: MIT

extends Node

class_name MeshSlicer

@export var material: Material

@onready var parent: Node3D = get_parent()

# Slice a mesh in half using Transform3D as the local position and direction. 
# Return an array of the sliced meshes. 
func slice_mesh(slice_transform: Transform3D, mesh: Mesh, cross_section_material: Material = null) -> Array[ArrayMesh]:
	if not is_inside_tree():
		#The node need to be in the tree for it to worked
		push_error("This node is not inside the tree")
		return [ArrayMesh.new(),ArrayMesh.new()]
	
	var combiner = CSGCombiner3D.new() 
	var obj_csg:CSGMesh3D = CSGMesh3D.new() # CSG that hold the main mesh
	obj_csg.mesh = mesh
	var slicer_csg:CSGMesh3D = CSGMesh3D.new() # CSG that is use to cut off the mesh
	slicer_csg.mesh = BoxMesh.new()
	slicer_csg.mesh.material = cross_section_material
	
	add_child(combiner)
	combiner.add_child(obj_csg)
	combiner.add_child(slicer_csg)
	slicer_csg.transform = slice_transform
	
	
	# Wrap the slicer CSG box on one side of the mesh
	var max_at = Vector3(-INF,-INF,-INF)
	var min_at = Vector3(INF,INF,INF)
	for v in mesh.get_faces():
		var lv = slicer_csg.to_local(v)
		max_at = max_at.max(lv)
		
		min_at = min_at.min(lv)
	min_at.z = 0
	slicer_csg.position = slicer_csg.to_global((max_at+min_at)/2.0)
	slicer_csg.mesh.size = (max_at-min_at)


	# Get the sliced meshes
	var out_mesh:Mesh
	var out_mesh2:Mesh
	
	slicer_csg.operation = CSGShape3D.OPERATION_SUBTRACTION
	combiner._update_shape()
	var meshes = combiner.get_meshes()
	if meshes:
		out_mesh = meshes[1]
		
	slicer_csg.operation = CSGShape3D.OPERATION_INTERSECTION
	combiner._update_shape()
	meshes = combiner.get_meshes()
	if meshes:
		out_mesh2 = meshes[1]
	
	# clean up	
	combiner.queue_free()
	
	
	return [out_mesh, out_mesh2]


func _on_sword_body_entered(body: Node) -> void:
	#The plane transform at the rigidbody local transform
	var mesh_instance = body.get_node("MeshInstance3D")
	if mesh_instance == null:
		return
		
	var transform = Transform3D.IDENTITY
	transform.origin = mesh_instance.to_local(parent.global_transform.origin)
	transform.basis.x = mesh_instance.to_local((parent.global_transform.basis.x + body.global_position))
	transform.basis.y = mesh_instance.to_local((parent.global_transform.basis.y + body.global_position))
	transform.basis.z = mesh_instance.to_local((parent.global_transform.basis.z + body.global_position))

	var collision = body.get_node("CollisionShape3D")
	
	#Slice the mesh
	var meshes = slice_mesh(transform, mesh_instance.mesh, material)

	mesh_instance.mesh = meshes[0]
	
	#generate collision
	if len(meshes[0].get_faces()) > 2:
		collision.shape = meshes[0].create_convex_shape()
	
	#adjust the rigidbody center of mass
	body.center_of_mass_mode = 1
	body.center_of_mass = body.to_local(mesh_instance.to_global(calculate_center_of_mass(meshes[0])))
	
	#recalculate mass
	var volume1 = calculate_mesh_volume(meshes[0])
	var volume2 = calculate_mesh_volume(meshes[1])
	var total_volume = volume1 + volume2

	var mass1 = body.mass * (volume1 / total_volume)
	var mass2 = body.mass * (volume2 / total_volume)

	body.mass = mass1
	
	
	#second half of the mesh
	var body2 = body.duplicate()
	print(body2.global_position)
	$"../../Sliced".add_child(body2)
	mesh_instance = body2.get_node("MeshInstance3D")
	collision = body2.get_node("CollisionShape3D")
	mesh_instance.mesh = meshes[1]
	body2.mass = mass2
	
	#generate collision
	if len(meshes[1].get_faces()) > 2:
		collision.shape = meshes[1].create_convex_shape()

	#get mesh size
	var aabb = meshes[0].get_aabb()
	var aabb2 = meshes[1].get_aabb()
	#queue_free() if the mesh is too small
	if aabb2.size.length() < 0.3:
		body2.queue_free()
	if aabb.size.length() < 0.3:
		body.queue_free()
		
	#adjust the rigidbody center of mass
	body2.center_of_mass = body2.to_local(mesh_instance.to_global(calculate_center_of_mass(meshes[1])))

func calculate_center_of_mass(mesh:ArrayMesh):
	#Not sure how well this work
	var meshVolume = 0
	var temp = Vector3(0,0,0)
	for i in range(len(mesh.get_faces())/3):
		var v1 = mesh.get_faces()[i]
		var v2 = mesh.get_faces()[i+1]
		var v3 = mesh.get_faces()[i+2]
		var center = (v1 + v2 + v3) / 3
		var volume = (Geometry3D.get_closest_point_to_segment_uncapped(v3,v1,v2).distance_to(v3)*v1.distance_to(v2))/2
		meshVolume += volume
		temp += center * volume
	
	if meshVolume == 0:
		return Vector3.ZERO
	return temp / meshVolume

func calculate_mesh_volume(mesh: ArrayMesh) -> float:
	var volume = 0.0
	for surface in range(mesh.get_surface_count()):
		var arrays = mesh.surface_get_arrays(surface)
		var vertices = arrays[Mesh.ARRAY_VERTEX]
		for i in range(0, vertices.size(), 3):
			var v1 = vertices[i]
			var v2 = vertices[i + 1]
			var v3 = vertices[i + 2]
			volume += abs(v1.dot(v2.cross(v3))) / 6.0
	return volume
