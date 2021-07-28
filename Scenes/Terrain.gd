tool

extends Spatial

const MAP_SIZE = 300
const TILE_SIZE = 5
const MAP_HEIGHT = 150
const WATER_HEIGHT = 50
const SAND_HEIGHT = -50
const GRASS_HEIGHT = 20
const ROCK_HEIGHT = 130

var height_map = []

func add_polygon_to_map(surface_tool, x, y, vertex_1, vertex_2, vertex_3):
	var variation1 = 0.6 + 0.4 * ((randi() % 10 + 1) / float(10))
	
	var color = Color(variation1, variation1, variation1)
	
	var avg_height = height_map[x][y] + height_map[x + 1][y] + height_map[x][y + 1]
			
	if avg_height < SAND_HEIGHT:
		color = Color(variation1, variation1, 0)
	elif avg_height < GRASS_HEIGHT:
		color = Color(0, variation1, 0)
	elif avg_height < ROCK_HEIGHT:
		color = Color(0.5 + (1 - variation1) * 0.5, 0.5 + (1 - variation1) * 0.5, 0.5 + (1 - variation1) * 0.5)
	
	surface_tool.add_normal(Vector3.UP)
	surface_tool.add_color(color)
	surface_tool.add_vertex(vertex_1)
	
	surface_tool.add_normal(Vector3.UP)
	surface_tool.add_color(color)
	surface_tool.add_vertex(vertex_2)
	
	surface_tool.add_normal(Vector3.UP)
	surface_tool.add_color(color)
	surface_tool.add_vertex(vertex_3)

func create_map():
	# Shift land up
	$Land.translation.y = float(MAP_HEIGHT) / 2
	
	# Setup water
	$Water.mesh.size.x = MAP_SIZE * TILE_SIZE
	$Water.mesh.size.y = MAP_SIZE * TILE_SIZE
	
	$Water.translation.x = $Water.mesh.size.x / 2
	$Water.translation.y = WATER_HEIGHT
	$Water.translation.z = $Water.mesh.size.y / 2
	
	# Setup OpenSimplexNoise
	var open_simplex_noise = OpenSimplexNoise.new()
	
	open_simplex_noise.seed = randi()
	open_simplex_noise.octaves = 4
	open_simplex_noise.period = 60.0
	open_simplex_noise.persistence = 0.8
	
	# Generate height map
	for x in range(MAP_SIZE + 1):
		var col = []
		
		for y in range(MAP_SIZE + 1):
			col.push_back(float(MAP_HEIGHT) * open_simplex_noise.get_noise_2d(x, y))
		
		height_map.push_back(col)
	
	# Create SurfaceTool, add vertices
	var surface_tool = SurfaceTool.new()
	
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	for x in range(MAP_SIZE):
		for y in range(MAP_SIZE):
			var vertex_1 = Vector3(x * TILE_SIZE, height_map[x][y], y * TILE_SIZE)
			var vertex_2 = Vector3((x + 1) * TILE_SIZE, height_map[x + 1][y], y * TILE_SIZE)
			var vertex_3 = Vector3(x * TILE_SIZE, height_map[x][y + 1], (y + 1) * TILE_SIZE)
			
			add_polygon_to_map(surface_tool, x, y, vertex_1, vertex_2, vertex_3)
			
			vertex_1 = Vector3((x + 1) * TILE_SIZE, height_map[x + 1][y], y * TILE_SIZE)
			vertex_2 = Vector3((x + 1) * TILE_SIZE, height_map[x + 1][y + 1], (y + 1) * TILE_SIZE)
			vertex_3 = Vector3(x * TILE_SIZE, height_map[x][y + 1], (y + 1) * TILE_SIZE)
			
			add_polygon_to_map(surface_tool, x, y, vertex_1, vertex_2, vertex_3)
	
	surface_tool.index()
	
	# Update changes to mesh
	$Land.mesh = surface_tool.commit()

func _ready():
	create_map()



