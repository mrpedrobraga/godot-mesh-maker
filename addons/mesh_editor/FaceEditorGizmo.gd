extends EditorNode3DGizmo

var base_gizmo : MeshEditorGizmo

# Finds the base gizmo, which contains all the shared data.
func _reset_base_gizmo(edited_node):
	if base_gizmo:
		return
	
	
	for gizmo in edited_node.get_gizmos():
		if gizmo is MeshEditorGizmo:
			base_gizmo = gizmo

func _redraw():
	clear()
	var edited_node = get_node_3d()
	_reset_base_gizmo(edited_node)
	
	var vertex_mesh = BoxMesh.new()
	vertex_mesh.size = Vector3(0.1, 0.1, 0.1)
	
	var handles_material = get_plugin().get_material("handles", self)
	
#	# Add handles for all the vertices.
#	add_handles(
#		base_gizmo.vertices.map(func(vertex): return vertex.position),
#		handles_material,
#		range(base_gizmo.vertices.size())
#	)
	
	for face_index in base_gizmo.faces.size():
		var face = base_gizmo.faces[face_index]
		add_mesh(
			vertex_mesh,
			get_plugin().get_material("face_mesh", self),
			Transform3D(
				Basis.IDENTITY,
				face.get_center()
			)
		)
	
#	for vert_index in base_gizmo.vertices.size():
#		var vertex = base_gizmo.vertices[vert_index]
#		add_mesh(
#			vertex_mesh,
#			get_plugin().get_material("edge_mesh", self),
#			Transform3D(Basis.IDENTITY, vertex.position)
#		)

## Handle dragging a selection box over vertices.
func _subgizmos_intersect_frustum(camera, frustum):
	var edited_node := get_node_3d()
	var result := []
	for face_index in base_gizmo.faces.size():
		var face = base_gizmo.faces[face_index]
		if enclosed_point(frustum, edited_node.to_global(face.get_center())):
			result.push_back(face_index)
	return result

## Checks if a point is inside a frustum.
func enclosed_point(frustum : Array[Plane], point : Vector3) -> bool:
	var below_all_planes = frustum.reduce(
		func(accum, plane):
			return accum and not plane.is_point_over(point)
	, true)
	return below_all_planes

## Handle clicking to select a vertex.
func _subgizmos_intersect_ray(camera, point):
	var edited_node := get_node_3d()
	for face_index in base_gizmo.faces.size():
		var face = base_gizmo.faces[face_index]
		if clicked_point(
			camera,
			point,
			edited_node.to_global(face.get_center())
		):
			return face_index
	return -1

## Radius of a vertex, for selection (in px).
const POINT_RADIUS = 32

## Checks if the point you clicked on-screen
## is close enough to the vertex.
func clicked_point(camera : Camera3D, clicked_point_screen : Vector2, target_point_world : Vector3) -> bool:
	var target_point_screen = camera.unproject_position(target_point_world)
	return target_point_screen.distance_to(clicked_point_screen) < POINT_RADIUS

func _commit_subgizmos(ids, restores, cancel):
	for index in ids.size():
		var face_index = ids[index]
		var restore = restores[index]
		
		#base_gizmo.vertices[vert_index].position = restore.origin
	base_gizmo.remake_mesh()
	
	_redraw()

func _get_subgizmo_transform(id):
	return Transform3D(Basis.IDENTITY, base_gizmo.faces[id].get_center())

func _set_subgizmo_transform(id, transform):
	var delta_transform := Transform3D(transform)
	var face = base_gizmo.faces[id]
	var center = face.get_center()
	delta_transform.translated(-center)
	
	for vertex in [face.vertex_a, face.vertex_b, face.vertex_c]:
		vertex.position.y = delta_transform.origin.y
