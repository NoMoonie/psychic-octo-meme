extends Spatial

export var acceleration : float = 15
export var air_acceleration : float = 5
export var gravity : float = 5
export var max_terminal_velocity : float = 54
export var rotation_speed : float = 7
export var speed : float = rand_range(3, 7)

var item = null
onready var mesh = $MeshInstance
# Not used in this script, but might be useful for child nodes because
# this controller will most likely be on the root
export(NodePath) var terrain = null

func _ready():
	mesh.mesh = item.item_referance.mesh
	mesh.material_override = item.item_referance.mesh_texture

var _velocity = Vector3()
var _grounded = false
var _box_mover = VoxelBoxMover.new()
var motor = Vector3()


var x = rand_range(-1, 1)
var z = rand_range(-1, 1)
func _physics_process(delta):
	if x == z:
		z = 0
	var	direction = Vector3()
	direction = Vector3(x,
	0,
	z).normalized()
	
	motor = direction * speed
	if speed > 0:
		speed -= 0.1
		direction = Vector3(0,0,0)
	else:
		speed = 0
	
	
	_velocity.x = motor.x
	_velocity.z = motor.z
	_velocity.y -= gravity * delta * acceleration
	
	if _grounded:
		$AnimationPlayer.play("wave")
		$AnimationPlayer.playback_speed = 0.5
	
	var motion = _velocity * delta
	if has_node(terrain):
		var aabb = AABB(Vector3(-0.4, 0, -0.4), Vector3(0.8, 1.8, 0.8))
		var terrain_node = get_node(terrain)
		var prev_motion = motion
		motion = _box_mover.get_motion(get_translation(), motion, aabb, terrain_node)
		isOnFloor(motion, prev_motion)
		global_translate(motion)

	assert(delta > 0)
	_velocity = motion / delta

func isOnFloor(motion : Vector3, prev_motion : Vector3):
	if abs(motion.y) < 0.001:
		if prev_motion.y < 0.001:
			_grounded = true
	else:
		_grounded = false

