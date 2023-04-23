@tool
extends EditorPlugin

var base_gizmo_plugin = preload("res://addons/mesh_editor/MeshEditorGizmoPlugin.gd")
var vertex_gizmo_plugin = preload("res://addons/mesh_editor/VertexEditorGizmoPlugin.gd")
var edge_gizmo_plugin = preload("res://addons/mesh_editor/EdgeEditorGizmoPlugin.gd")
var face_gizmo_plugin = preload("res://addons/mesh_editor/FaceEditorGizmoPlugin.gd")

var mesh_editor_bottom_panel = preload("res://addons/mesh_editor/mesh_editor_dock.tscn")

func _enter_tree():
	base_gizmo_plugin = base_gizmo_plugin.new()
	vertex_gizmo_plugin = vertex_gizmo_plugin.new()
	edge_gizmo_plugin = edge_gizmo_plugin.new()
	face_gizmo_plugin = face_gizmo_plugin.new()
	add_node_3d_gizmo_plugin(base_gizmo_plugin)
	add_node_3d_gizmo_plugin(vertex_gizmo_plugin)
	add_node_3d_gizmo_plugin(edge_gizmo_plugin)
	add_node_3d_gizmo_plugin(face_gizmo_plugin)
	
	mesh_editor_bottom_panel = mesh_editor_bottom_panel.instantiate()
	add_control_to_bottom_panel(mesh_editor_bottom_panel, "Mesh Editor")

func _exit_tree():
	remove_control_from_bottom_panel(mesh_editor_bottom_panel)
	
	remove_node_3d_gizmo_plugin(face_gizmo_plugin)
	remove_node_3d_gizmo_plugin(edge_gizmo_plugin)
	remove_node_3d_gizmo_plugin(vertex_gizmo_plugin)
	remove_node_3d_gizmo_plugin(base_gizmo_plugin)
