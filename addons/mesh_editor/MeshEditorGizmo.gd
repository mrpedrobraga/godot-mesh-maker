extends EditorNode3DGizmo
class_name MeshEditorGizmo

## The [MeshDataTool]s for each of the mesh surfaces.[br]
## They are ordered by the surface's index on the mesh.;
var surface_mesh_tools : Array[MeshDataTool]

var undo_redo : EditorUndoRedoManager

## The class for vertices.
class Vertex:
	var index : int
	var surface_index : int
	var position : Vector3
	func _to_string():
		return str(position)

## The class for edges.
class Edge:
	var index : int
	var surface_index : int
	var vertex_a : Vertex
	var vertex_b : Vertex
	func get_center() -> Vector3:
		return (
			vertex_a.position +\
			vertex_b.position
		) / 2.0

## The class for efaces.
class Face:
	var index : int
	var surface_index : int
	var edge_ab : Edge
	var edge_bc : Edge
	var edge_ac : Edge
	var vertex_a : Vertex
	var vertex_b : Vertex
	var vertex_c : Vertex
	func get_center() -> Vector3:
		return (
			vertex_a.position +\
			vertex_b.position +\
			vertex_c.position
		) / 3.0

## An array of vertices (their indexes are their ids).
var vertices : Array[Vertex] = []
## An array of vertices (their indexes are their ids).
var edges : Array[Edge] = []
## An array of vertices (their indexes are their ids).
var faces : Array[Face] = []

## Whether this gizmo has been setup properly.[br]
## If false, it calls [method _setup] on the next redraw.
var has_setup : bool = false

## Sets up the Gizmo.
func _setup():
	# Gets the edited node.
	var edited_node := get_node_3d()
	
	# If no mesh, return.
	if not edited_node.mesh: return
	
	surface_mesh_tools.clear()
	
	## EXTRACTING ALL THE MESH PRIMITIVES ##
	vertices.clear()
	edges.clear()
	faces.clear()
	for surface_index in edited_node.mesh.get_surface_count():
		var mesh_data_tool = MeshDataTool.new()
		mesh_data_tool.create_from_surface(edited_node.mesh, surface_index)
		surface_mesh_tools.push_back(mesh_data_tool)
		
		mesh_data_tool.create_from_surface(edited_node.mesh, 0)
		
		# Gather all the vertices.
		for vertex_index in mesh_data_tool.get_vertex_count():
			var v := Vertex.new()
			v.index = vertex_index
			v.surface_index = surface_index
			v.position = mesh_data_tool.get_vertex(vertex_index)
			vertices.push_back(v)
		
		# Gather all the edges.
		for edge_index in mesh_data_tool.get_edge_count():
			var edge = Edge.new()
			edge.index = edge_index
			edge.surface_index = surface_index
			edge.vertex_a = vertices[mesh_data_tool.get_edge_vertex(edge_index, 0)]
			edge.vertex_b = vertices[mesh_data_tool.get_edge_vertex(edge_index, 1)]
			edges.push_back(edge)
		
		# Gather all the faces.
		for face_index in mesh_data_tool.get_face_count():
			var face = Face.new()
			face.index = face_index
			face.surface_index = surface_index
			face.edge_ab = edges[mesh_data_tool.get_face_edge(face_index, 0)]
			face.edge_bc = edges[mesh_data_tool.get_face_edge(face_index, 1)]
			face.edge_ac = edges[mesh_data_tool.get_face_edge(face_index, 2)]
			face.vertex_a = vertices[mesh_data_tool.get_face_vertex(face_index, 0)]
			face.vertex_b = vertices[mesh_data_tool.get_face_vertex(face_index, 1)]
			face.vertex_c = vertices[mesh_data_tool.get_face_vertex(face_index, 2)]
			faces.push_back(face)

# The redraw function, which extracts all the information about the mesh.
# Doing this here is definitely silly wasteful, so it should be moved.
func _redraw():
	clear()
	var material = get_plugin().get_material("main", self)
	
	# Set the gizmo up if it wasn't already done.
	if not has_setup:
		_setup()

# Gets the name of a vertex, from its ID.
func _get_handle_name(id, secondary):
	return "Vertex"

# A vertex's value is its position.
func _get_handle_value(id, secondary):
	return vertices[id].position

func remake_mesh():
	var edited_node := get_node_3d()
	
	# This here is very, very incorrect;
	# Not sure how to solve this, but [surface_remove] went missing.
	# Ideally, there should be a way of comitting to a surface without reordering
	# it.
	edited_node.mesh.clear_surfaces()
	
	for vertex in vertices:
		surface_mesh_tools[vertex.surface_index].set_vertex(vertex.index, vertex.position)
		# Commits the changes.
	
	for smt in surface_mesh_tools:
		smt.commit_to_surface(edited_node.mesh)
