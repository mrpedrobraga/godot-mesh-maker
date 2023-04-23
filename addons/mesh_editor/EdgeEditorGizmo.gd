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
	
	# Add handles for all the vertices.
#	add_handles(
#		base_gizmo.vertices.map(func(vertex): return vertex.position),
#		handles_material,
#		range(base_gizmo.vertices.size())
#	)
	
	# Add lines for all the edges.
	var edge_vertices : PackedVector3Array = []
	for e in base_gizmo.edges:
		edge_vertices.push_back(e.vertex_a.position)
		edge_vertices.push_back(e.vertex_b.position)
	add_lines(edge_vertices, get_plugin().get_material("main", self), false, Color.WHITE)
	
#	for edge_index in base_gizmo.edges.size():
#		var edge = base_gizmo.edges[edge_index]
#		add_mesh(
#			vertex_mesh,
#			get_plugin().get_material("edge_mesh", self),
#			Transform3D(
#				Basis.IDENTITY,
#				lerp(edge.vertex_a.position, edge.vertex_b.position, 0.5)
#			)
#		)
	
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
	for vert_index in base_gizmo.vertices.size():
		var vertex = base_gizmo.vertices[vert_index]
		if enclosed_point(frustum, edited_node.to_global(vertex.position)):
			result.push_back(vert_index)
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
	for vert_index in base_gizmo.vertices.size():
		var vertex = base_gizmo.vertices[vert_index]
		if clicked_point(
			camera,
			point,
			edited_node.to_global(vertex.position)
		):
			return vert_index
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
		var vert_index = ids[index]
		var restore = restores[index]
		
		#base_gizmo.vertices[vert_index].position = restore.origin
	base_gizmo.remake_mesh()
	
	_redraw()

func _get_subgizmo_transform(id):
	return Transform3D(Basis.IDENTITY, base_gizmo.vertices[id].position)

func _set_subgizmo_transform(id, transform):
	base_gizmo.vertices[id].position = transform.origin
