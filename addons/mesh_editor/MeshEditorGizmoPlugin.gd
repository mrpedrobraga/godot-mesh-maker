extends EditorNode3DGizmoPlugin

var editor_handle_3d_texture := preload("res://addons/mesh_editor/editor_handle_3d.png")
func _init():
	create_material("main", Color(1, 1, 1))
	create_handle_material("handles", false, editor_handle_3d_texture)

func _create_gizmo(node):
	if _can_be_edited(node):
		return MeshEditorGizmo.new()
	return null

func _can_be_edited(node):
	return &"mesh" in node

func _get_gizmo_name():
	return "Mesh Editor (Base)"
