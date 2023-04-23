extends EditorNode3DGizmo

## The [MeshDataTool]s for each of the mesh surfaces.[br]
## They are ordered by the surface's index on the mesh.;
var surface_mesh_tools : Array[MeshDataTool]

## The class for vertices.
class Vertex:
	var index : int
	var surface_index : int
	var position : Vector3

## The class for edges.
class Edge:
	var vertex_a : Vertex
	var vertex_b : Vertex

## The class for efaces.
class Face:
	var edge_ab : Edge
	var edge_bc : Edge
	var edge_ac : Edge

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
			edge.vertex_a = vertices[mesh_data_tool.get_edge_vertex(edge_index, 0)]
			edge.vertex_b = vertices[mesh_data_tool.get_edge_vertex(edge_index, 0)]
			edges.push_back(edge)

# The redraw function, which extracts all the information about the mesh.
# Doing this here is definitely silly wasteful, so it should be moved.
func _redraw():
	clear()
	var material = get_plugin().get_material("main", self)
	var handles_material = get_plugin().get_material("handles", self)
	
	# Set the gizmo up if it wasn't already done.
	if not has_setup:
		_setup()
	
	# Add lines for all the edges.
	var edge_vertices : PackedVector3Array = []
	for e in edges:
		edge_vertices.push_back(e.vertex_a.position + Vector3.UP)
		edge_vertices.push_back(e.vertex_b.position + Vector3.UP)
	add_lines(edge_vertices, material, false, Color.WHITE)
	
	# Add handles for all the vertices.
	add_handles(
		vertices.map(func(vertex): return vertex.position),
		handles_material,
		range(vertices.size())
	)

# Gets the name of a vertex, from its ID.
func _get_handle_name(id, secondary):
	return "Vertex"

# A vertex's value is its position.
func _get_handle_value(id, secondary):
	return vertices[id].position

# Handles moving a vector in the screen.
func _set_handle(id : int, secondary : bool, camera : Camera3D, point : Vector2):
	# The current vertex being edited:
	var vertex := vertices[id]
	# The currently edited node.
	var edited_node := get_node_3d()
	# The [MeshDataTool] associated with the current surface.
	var mesh_data_tool = surface_mesh_tools[vertex.surface_index]
	
	# Create the mesh data based on the surface.
	# TODO: store a mesh data tool for each surface already.
	mesh_data_tool.create_from_surface(edited_node.mesh, vertex.surface_index)
	
	# Calculate the original position.
	var og_handle_position = vertex.position + get_node_3d().global_position
	# Calculate the original Z depth of the vertex.
	var og_handle_depth = - camera.to_local(og_handle_position).z

	# Move the handle in "2D" space while keeping the same distance from the camera.
	var result = camera.project_position(point, og_handle_depth) - get_node_3d().global_position
	# Set the vertex.
	mesh_data_tool.set_vertex(vertex.index, result)
	
	# This here is very, very incorrect;
	# Not sure how to solve this, but [surface_remove] went missing.
	# Ideally, there should be a way of comitting to a surface without reordering
	# it.
	edited_node.mesh.clear_surfaces()
	
	# Commits the changes.
	mesh_data_tool.commit_to_surface(edited_node.mesh)

	# Redraws.
	_redraw()
