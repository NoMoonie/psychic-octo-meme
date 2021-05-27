extends VoxelGeneratorScript

const Structure = preload("./structure.gd")
const TreeGenerator = preload("res://World/generator/treeGenerator.gd")
const hMap = preload("res://World/generator/curves/heightmap_curve.tres")

const AIR = 0
const DIRT = 1
const GRASS = 2
const WATER_TOP = 3
const WATER_FULL = 4
const STONE = 5
const LOG = 7
const LEAVES = 9
const FLOWER = 10
const MOSHROOM = 11


const channel : int = VoxelBuffer.CHANNEL_TYPE

const _moore_dirs = [
	Vector3(-1, 0, -1),
	Vector3(0, 0, -1),
	Vector3(1, 0, -1),
	Vector3(-1, 0, 0),
	Vector3(1, 0, 0),
	Vector3(-1, 0, 1),
	Vector3(0, 0, 1),
	Vector3(1, 0, 1)
]

var _tree_structures := []

var _heightmap_min_y := int(hMap.min_value)
var _heightmap_max_y := int(hMap.max_value)
var _heightmap_range := 0
var _heightmap_noise := OpenSimplexNoise.new()
var _trees_min_y := 0
var _trees_max_y := 0

func _get_used_channels_mask() -> int:
	return 1 << channel

func _init():
	#tree structure
	var tree_generator = TreeGenerator.new()
	tree_generator.log_type = LOG
	tree_generator.leaves_type = LEAVES
	for i in 16:
		var s = tree_generator.generate()
		_tree_structures.append(s)

	var tallest_tree_height = 0
	for structure in _tree_structures:
		var h = int(structure.voxels.get_size().y)
		if tallest_tree_height < h:
			tallest_tree_height = h
	_trees_min_y = _heightmap_min_y
	_trees_max_y = _heightmap_max_y + tallest_tree_height
	
	

	#ground gen
	_heightmap_noise.seed = 0
	_heightmap_noise.octaves = 3
	_heightmap_noise.persistence = 0.5
	_heightmap_noise.lacunarity = 1.5
	_heightmap_noise.period = 200
	hMap.bake()

func _generate_block(buffer : VoxelBuffer, origin : Vector3, lod : int) -> void:
	buffer.set_channel_depth(channel, VoxelBuffer.DEPTH_8_BIT)

	var chunk_pos := Vector3(
		int(origin.x) >> 4,
		int(origin.y) >> 4,
		int(origin.z) >> 4)

	_heightmap_range = _heightmap_max_y - _heightmap_min_y

	var block_size := int(buffer.get_size().x)
	var oy := int(origin.y)


	if lod != 0:
		return
	if origin.y > _heightmap_max_y:
		buffer.fill(AIR, channel)
	elif origin.y + block_size < _heightmap_min_y:
		buffer.fill(STONE, channel)

	else:
		var rng := RandomNumberGenerator.new()
		rng.seed = _get_chunk_seed_2d(chunk_pos)
		
		var gx : int
		var gz := int(origin.z)

		for z in block_size:
			gx = int(origin.x)

			for x in block_size:
				var height := _get_height_at(gx, gz)
				var relative_height := height - oy

				# Dirt and grass
				if relative_height > block_size:
					buffer.fill_area(DIRT,
						Vector3(x, 0, z), Vector3(x + 1, block_size, z + 1), channel)
				elif relative_height > 0:
					buffer.fill_area(DIRT,
						Vector3(x, 0, z), Vector3(x + 1, relative_height, z + 1), channel)
					if height >= 0:
						buffer.set_voxel(GRASS, x, relative_height - 1, z, channel)
						if relative_height < block_size and rng.randf() < 0.01:
							var foliage = FLOWER
							if rng.randf() < 0.02:
								foliage = MOSHROOM
							buffer.set_voxel(foliage, x, relative_height, z, channel)


				#water
				if height < 0 and oy < 0:
					var start_relative_height := 0
					if relative_height > 0:
						start_relative_height = relative_height
					buffer.fill_area(WATER_FULL,
						Vector3(x, start_relative_height, z),
						Vector3(x + 1, block_size, z + 1), channel)
					if oy + block_size == 0:
						# Surface block
						buffer.set_voxel(WATER_TOP, x, block_size - 1, z, channel)
				gx += 1

			gz += 1
	#tree
	if origin.y <= _trees_max_y and origin.y + block_size >= _trees_min_y:
		var voxel_tool := buffer.get_voxel_tool()
		var structure_instances := []

		getTreeInstanceInChunk(chunk_pos, origin, block_size, structure_instances)

		# Relative to current block
		var block_aabb := AABB(Vector3(), buffer.get_size() + Vector3(1, 1, 1))

		for dir in _moore_dirs:
			var ncpos : Vector3 = (chunk_pos + dir).round()
			getTreeInstanceInChunk(ncpos, origin, block_size, structure_instances)

		for structure_instance in structure_instances:
			var pos : Vector3 = structure_instance[0]
			var structure : Structure = structure_instance[1]
			var lower_corner_pos := pos - structure.offset
			var aabb := AABB(lower_corner_pos, structure.voxels.get_size() + Vector3(1, 1, 1))

			if aabb.intersects(block_aabb):
				voxel_tool.paste(lower_corner_pos,
					structure.voxels, 1 << VoxelBuffer.CHANNEL_TYPE, AIR)



	buffer.optimize()

func getTreeInstanceInChunk(cPos: Vector3, offset: Vector3, chunkSize : int, treeInstances: Array):
	var rng := RandomNumberGenerator.new()
	rng.seed = _get_chunk_seed_2d(cPos)

	for i in 4:
		var pos := Vector3(rng.randi() % 96, 0, rng.randi() % 96)
		pos += cPos * chunkSize
		pos.y = _get_height_at(pos.x, pos.z)

		if pos.y > 0:
			pos -= offset
			var si := rng.randi() % len(_tree_structures)
			var structure : Structure = _tree_structures[si]
			treeInstances.append([pos.round(), structure])



static func _get_chunk_seed_2d(cpos: Vector3) -> int:
	return int(cpos.x) ^ (63 * int(cpos.z))

func _get_height_at(x: int, z: int) -> int:
	var t = 0.5 + 0.5 * _heightmap_noise.get_noise_2d(x, z)
	return int(hMap.interpolate_baked(t))
