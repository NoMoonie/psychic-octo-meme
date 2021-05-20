extends VoxelGeneratorScript

const channel : int = VoxelBuffer.CHANNEL_TYPE
const hMap = preload("res://World/generator/curves/heightmap_curve.tres")

const AIR = 0
const DIRT = 1
const GRASS = 2
const WATER_TOP = 3
const WATER_FULL = 4
const STONE = 5

var _heightmap_min_y := int(hMap.min_value)
var _heightmap_max_y := int(hMap.max_value)
var _heightmap_range := 0
var _heightmap_noise := OpenSimplexNoise.new()

func _get_used_channels_mask() -> int:
	return 1 << channel
	
func _init():
	_heightmap_noise.seed = 1244
	_heightmap_noise.octaves = 4
	_heightmap_noise.period = 128
	_heightmap_noise.persistence = 0.5
	hMap.bake()

func _generate_block(buffer : VoxelBuffer, origin : Vector3, lod : int) -> void:
	buffer.set_channel_depth(channel, VoxelBuffer.DEPTH_8_BIT)
	
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

	buffer.optimize()
				
func _get_height_at(x: int, z: int) -> int:
	var t = 0.5 + 0.5 * _heightmap_noise.get_noise_2d(x, z)
	return int(hMap.interpolate_baked(t))
