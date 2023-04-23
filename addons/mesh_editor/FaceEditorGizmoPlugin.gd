extends EditorNode3DGizmoPlugin

var FaceEditorGizmo := preload("res://addons/mesh_editor/FaceEditorGizmo.gd")

var editor_handle_3d_texture := preload("res://addons/mesh_editor/editor_handle_3d_green.png")

func _init():
	create_material("main", Color(1, 1, 1))
	create_material(
		"face_mesh",
		Color(0, 0.76365691423416, 0.51762747764587),
		false, true
	)
	create_handle_material("handles", false, editor_handle_3d_texture)
	create_handle_material("unselected_vertex", false, preload("res://addons/mesh_editor/editor_handle_3d_yellow.png"))

func _create_gizmo(node):
	if _can_be_edited(node):
		return FaceEditorGizmo.new()
	return null

func _can_be_edited(node):
	return &"mesh" in node

func _get_gizmo_name():
	return "Mesh Editor (Face)"
