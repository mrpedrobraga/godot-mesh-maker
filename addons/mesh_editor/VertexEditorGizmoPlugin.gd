extends EditorNode3DGizmoPlugin

var VertexEditorGizmo := preload("res://addons/mesh_editor/VertexEditorGizmo.gd")

var editor_handle_3d_texture := preload("res://addons/mesh_editor/editor_handle_3d.png")

func _init():
	create_material("main", Color(1, 1, 1))
	create_material(
		"vertex_mesh",
		Color(0.96810764074326, 0.24348595738411, 0.58922570943832),
		false, true
	)
	create_handle_material("handles", false, editor_handle_3d_texture)
	create_handle_material("unselected_vertex", false, preload("res://addons/mesh_editor/editor_handle_3d_purple.png"))

func _create_gizmo(node):
	if _can_be_edited(node):
		return VertexEditorGizmo.new()
	return null

func _can_be_edited(node):
	return &"mesh" in node

func _get_gizmo_name():
	return "Mesh Editor (Vertex)"
