extends EditorNode3DGizmoPlugin

var VertexEditorGizmo := preload("res://addons/mesh_editor/VertexEditorGizmo.gd")

var editor_handle_3d_texture := preload("res://addons/mesh_editor/editor_handle_3d.png")

func _init():
	create_material("main", Color(1, 1, 1))
	create_handle_material("vertex_selected", false, editor_handle_3d_texture)
	create_handle_material("vertex", false, preload("res://addons/mesh_editor/editor_handle_3d_purple.png"))

func _create_gizmo(node):
	if _can_be_edited(node):
		return VertexEditorGizmo.new()
	return null

func _can_be_edited(node):
	return &"mesh" in node

func _get_gizmo_name():
	return "Mesh Editor (Vertex)"
