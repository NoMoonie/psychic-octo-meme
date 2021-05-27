extends Spatial

export var acceleration : float = 15
export var air_acceleration : float = 5
export var gravity : float = 5
export var max_terminal_velocity : float = 54
export var rotation_speed : float = 7

# Not used in this script, but might be useful for child nodes because
# this controller will most likely be on the root
export(NodePath) var terrain = null

var _velocity = Vector3()
var _grounded = false
var _box_mover = VoxelBoxMover.new()

func _physics_process(delta):
	
	
	#_velocity.x = motor.x
	#_velocity.z = motor.z
	_velocity.y -= gravity * delta * acceleration
	
	if _grounded:
		$AnimationPlayer.play("wave")
		$AnimationPlayer.playback_speed = 1
	
	var motion = _velocity * delta
	print(motion)
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

