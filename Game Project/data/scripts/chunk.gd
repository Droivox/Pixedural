extends Node3D

var renderDistance = 5;
var cubeSize : float = 0.5;
var chunkSize : int = 16;

@export var generateWorld : bool = false;

var blockTop = {"grass": Vector2(0, 0), "dirt": Vector2(5, 0)};

@export var uvSize = Vector2(0.0625, 0.0625);

var terrainPerlin : = {};
var treePerlin : = {};
var grassPerlin : = {};

var blocks = [];

var threads = [];

var preTree = preload("res://data/scenes/tree.tscn");

var thread = Thread.new();

@export var render : Marker3D;

var preWater = preload("res://data/scenes/water.tscn");
var preGrass = preload("res://data/scenes/grass.tscn");

func _ready() -> void:
	randomize();
	
	for n in $Noises.get_children():
		n.texture.noise.seed = randi();
		terrainPerlin[str(n.name)] = n.texture.noise;
	
	for n in $Tree.get_children():
		n.texture.noise.seed = randi();
		treePerlin[str(n.name)] = n.texture.noise;
	
	for n in $Grass.get_children():
		n.texture.noise.seed = randi();
		grassPerlin[str(n.name)] = n.texture.noise;
	
	if not thread.is_started():
		thread.start(generateTerrain);

func _process(_delta):
	render.position = get_viewport().get_camera_3d().global_position;

func generateTerrain():
	var chunks = {};
	
	while true:
		var grid_x = int(render.global_transform.origin.x / chunkSize) * chunkSize;
		var grid_z = int(render.global_transform.origin.z / chunkSize) * chunkSize;
		var grid = Vector3i(grid_x, 0, grid_z);
		
		var localChunks = [];
		
		for x in range(-renderDistance, renderDistance):
			for z in range(-renderDistance, renderDistance):
				var snap = Vector3i(grid.x + (x * chunkSize), 0, grid.z + (z * chunkSize));
				
				localChunks.append(snap);
				
				if not str(snap) in chunks:
					@warning_ignore("unused_variable")
					var ch = generateChunk(snap);
					chunks[str(snap)] = snap;

func _exit_tree():
	thread.await_to_finish();

func generateTerrainHeight(_position : Vector3i) -> float:
	var heightFloat = 0.0;
	
	var snap = 1;
	
	var pos = Vector3(_position.x * snap, 0, _position.z * snap);
	
	var height = {};
	
	for p in terrainPerlin:
		match p:
			"normal":
				height["normal"] = sin(terrainPerlin[p].get_noise_2d(pos.x * 0.2, pos.z * 0.2)) * 16;
				height["normal"] = clamp(height["normal"], 0, 50);
			"mountain":
				var mountain = sin(terrainPerlin[p].get_noise_2d(pos.x * 0.2, pos.z * 0.2)) * 52;
				mountain = clamp(mountain, 0, 50);
				height["mountain"] = mountain;
			"lake":
				var lake = sin(terrainPerlin[p].get_noise_2d(pos.x * 0.5, pos.z * 0.5)) * 12;
				lake = clamp(lake, -6, 0.3);
				height["lake"] = lake;
			
	for h in height:
		heightFloat += height[h];
	
	return heightFloat;

func generateChunk(_position : Vector3i):
	var waterGenerator = false;
	
	var surface = SurfaceTool.new();
	var mesh = MeshInstance3D.new();
	
	mesh.set_layer_mask_value(6, true);
	
	surface.begin(Mesh.PRIMITIVE_TRIANGLES);
	surface.set_smooth_group(true);
	
	for x in range(chunkSize):
		for z in range(chunkSize):
			
			var pos = Vector3(_position.x + x, 0, _position.z + z);
			
			#generateGrass(pos, mesh);
			generateTree(pos, mesh);
			cubeTop(surface, pos);

	mesh.mesh = surface.commit();
	mesh.call_deferred("create_trimesh_collision");
	mesh.material_override = load("res://data/materials/terrain.material");
	
	mesh.name = str(_position);
	
	var water = preWater.instantiate();
	water.position = Vector3(_position.x, _position.y - 0.5, _position.z);
	mesh.call_deferred("add_child", water);
	
	$Chunks.call_deferred("add_child", mesh);
	
	return mesh;

func generateTree(_position, mesh) -> void:
	
	var TreeAreaNoise = 0;
	
	var treeDistanceNoise = 0;
	var TreeDistance = 64;
	
	for p in treePerlin:
		match p:
			"TreePerlin":
				TreeAreaNoise = sin(treePerlin[p].get_noise_2d(_position.x * 16, _position.z * 16));
			"TreeDistancePerlin":
				treeDistanceNoise = sin(treePerlin[p].get_noise_2d(_position.x * TreeDistance, _position.z * TreeDistance));
	
	var ht = generateTerrainHeight(_position);
	
	treeDistanceNoise = clamp(treeDistanceNoise, 0, 1);
	TreeDistance = clamp(TreeDistance, 0, 1);
	
	var pos = _position + Vector3(0, ht, 0);
	
	if TreeAreaNoise > 0.4 and treeDistanceNoise > 0.5 and pos.y > 0.1 and pos.y < 1.0:
		var tree = preTree.instantiate();
		tree.position = pos;
		mesh.call_deferred("add_child", tree);

func generateGrass(_position, mesh) -> void:
	
	var grassAreaNoise = 0;
	
	var grassDistanceNoise = 0;
	var grassDistance = 64;
	
	for p in grassPerlin:
		match p:
			"GrassPerlin":
				grassAreaNoise = sin(grassPerlin[p].get_noise_2d(_position.x * 16, _position.z * 16));
			"GrassDistancePerlin":
				grassDistanceNoise = sin(grassPerlin[p].get_noise_2d(_position.x * grassDistance, _position.z * grassDistance));
	
	var ht = generateTerrainHeight(_position);
	
	grassDistanceNoise = clamp(grassDistanceNoise, 0, 1);
	grassDistance = clamp(grassDistance, 0, 1);
	
	var pos = _position + Vector3(0, ht, 0);
	
	if grassAreaNoise > 0.1 and grassDistanceNoise > 0.2 and pos.y > 0.1 and pos.y < 2.0:
		var grass = preGrass.instantiate();
		grass.position = pos;
		mesh.call_deferred("add_child", grass);

func cubeTop(_surface, _position) -> void:
	var uv_origin = uvSize;
	var uv_top_right = uv_origin + Vector2(uvSize.x, 0);
	var uv_bottom_right = uv_origin + Vector2(uvSize.x, uvSize.y);
	var uv_bottom_left = uv_origin + Vector2(0, uvSize.y);

	_surface.set_uv(uv_origin)
	var ht = generateTerrainHeight(_position + Vector3(-cubeSize, cubeSize, -cubeSize));
	_surface.add_vertex(_position + Vector3(-cubeSize, ht, -cubeSize))

	_surface.set_uv(uv_top_right)
	ht = generateTerrainHeight(_position + Vector3(cubeSize, cubeSize, -cubeSize));
	_surface.add_vertex(_position + Vector3(cubeSize, ht, -cubeSize))

	_surface.set_uv(uv_bottom_right)
	ht = generateTerrainHeight(_position + Vector3(cubeSize, cubeSize, cubeSize));
	_surface.add_vertex(_position + Vector3(cubeSize, ht, cubeSize))

	_surface.set_uv(uv_origin)
	ht = generateTerrainHeight(_position + Vector3(-cubeSize, cubeSize, -cubeSize));
	_surface.add_vertex(_position + Vector3(-cubeSize, ht, -cubeSize))

	_surface.set_uv(uv_bottom_right)
	ht = generateTerrainHeight(_position + Vector3(cubeSize, cubeSize, cubeSize));
	_surface.add_vertex(_position + Vector3(cubeSize, ht, cubeSize))

	_surface.set_uv(uv_bottom_left)
	ht = generateTerrainHeight(_position + Vector3(-cubeSize, cubeSize, cubeSize));
	_surface.add_vertex(_position + Vector3(-cubeSize, ht, cubeSize))
