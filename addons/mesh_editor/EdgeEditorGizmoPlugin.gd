extends EditorNode3DGizmoPlugin

var EdgeEditorGizmo := preload("res://addons/mesh_editor/EdgeEditorGizmo.gd")

var editor_handle_3d_texture := preload("res://addons/mesh_editor/editor_handle_3d.png")

func _init():
	create_material("main", Color(1, 1, 1))
	create_material(
		"edge_mesh",
		Color(0.84425383806229, 0.5926274061203, 0.02630249224603),
		false, true
	)
	create_handle_material("handles", false, editor_handle_3d_texture)
	create_handle_material("unselected_vertex", false, preload("res://addons/mesh_editor/editor_handle_3d_yellow.png"))

func _create_gizmo(node):
	if _can_be_edited(node):
		return EdgeEditorGizmo.new()
	return null

func _can_be_edited(node):
	return &"mesh" in node

func _get_gizmo_name():
	return "Mesh Editor (Edge)"
