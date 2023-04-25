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
	
	var vertex_mesh = PointMesh.new()

	var selected_vertices = get_subgizmo_selection()
	
	for vert_index in base_gizmo.vertices.size():
		var vertex = base_gizmo.vertices[vert_index]
		var material = get_plugin().get_material(
				"vertex_selected" if vert_index in selected_vertices\
				else "vertex",
				self
			)
		add_mesh(
			vertex_mesh,
			material,
			Transform3D(Basis.IDENTITY, vertex.position)
		)

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
	print('Committing subgizmos.')
	
	if cancel:
		for i in ids.size():
			base_gizmo.vertices[ids[i]].position = restores[i].origin
			_redraw()
			return
	
	var ur := base_gizmo.undo_redo
	print(ur)
	ur.create_action("Transform Vertices", UndoRedo.MERGE_DISABLE)
	
	for index in ids.size():
		var vert_index = ids[index]
		var restore = restores[index]
		
		ur.add_do_method(base_gizmo, &"remake_mesh")
		ur.add_undo_method(base_gizmo, &"remake_mesh")
		ur.add_do_property(base_gizmo.vertices[vert_index], &'position', base_gizmo.vertices[vert_index].position)
		ur.add_undo_property(base_gizmo.vertices[vert_index], &'position', restore)
	base_gizmo.remake_mesh()
	
	ur.commit_action()
	
	_redraw()

func _get_subgizmo_transform(id):
	return Transform3D(Basis.IDENTITY, base_gizmo.vertices[id].position)

func _set_subgizmo_transform(id, transform):
	base_gizmo.vertices[id].position = transform.origin
