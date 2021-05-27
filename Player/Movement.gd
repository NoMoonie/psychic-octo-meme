extends KinematicBody

const Util = preload("res://common/util.gd")


#player movement
export(int, 1, 50) var walkSpeed : int = 10
export(int, 1, 100) var spintSpeed : int = 15
var movementSpeed : int = 0
export var acceleration : float = 15
export var air_acceleration : float = 5
export var gravity : float = 5
export var max_terminal_velocity : float = 54
export var jump_power : float = 17
export var rotation_speed : float = 7
export var Flying : bool = false

#box mover collitions
export(NodePath) var terrain = null
var boxMover = VoxelBoxMover.new()

#camera zoom
export(int, 5, 20) var minZoom : int = 5
export(int, 1, 50) var maxZoom : int = 20
export(float, 0, 1000, 0.1) var zoomSpeed : float = 20
export(float, 0, 1, 0.1) var zoomSpeedDamp : float = 0.5
var _zoomDir = 0

#move vector
var velocity : Vector3
var y_velocity : float

#camera
onready var camera_pivot = $camRoot
onready var camera = $camRoot/h/v/Camera
onready var animPlayer = $playerModel/AnimationPlayer

var _terrain_tool = null
var _grounded = false

var inv_res = load("res://Scipts/inventory/inventory.gd")
var inventory = inv_res.new()

func _ready():
	
	boxMover.set_collision_mask(1)
	var terrain = get_parent().get_node("VoxelTerrain")
	_terrain_tool = terrain.get_voxel_tool()
	
func _input(event):
	if event.is_action_pressed("camera_zoom_in"):
		_zoomDir = -1
	if event.is_action_pressed("camera_zoom_out"):
		_zoomDir = 1

func _physics_process(delta):
	cameraZoom(delta)
	Movement(delta)
	

func Movement(delta):
	var motor = Vector3()
	var h_rot = $camRoot/h.global_transform.basis.get_euler().y
	var direction = Vector3()
	direction = Vector3(Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
	0,
	Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward")).rotated(Vector3.UP, h_rot).normalized()
	
	if direction != Vector3.ZERO:
		var hit = getPointVoxel($playerModel)
		#rotate in the moving direction
		$playerModel.rotation.y = lerp_angle($playerModel.rotation.y, atan2(-direction.x, -direction.z), delta * rotation_speed)
		#animate player model
		animPlayer.playback_speed = movementSpeed / 6.0
		animPlayer.play("walking")
		#run
		if Input.is_action_pressed("sprint") and !Flying:
			movementSpeed = spintSpeed
		else:
			movementSpeed = walkSpeed
	else:
		animPlayer.playback_speed = 1.0
		animPlayer.play("idle")
		
	motor = direction * movementSpeed
	
	velocity.x = motor.x
	velocity.z = motor.z
	velocity.y -= gravity * delta * acceleration
	
	if _grounded and Input.is_action_pressed("jump"):
		velocity.y = jump_power
	
	var motion = velocity * delta
	if has_node(terrain):
		var aabb = AABB(Vector3(-0.4, 0, -0.4), Vector3(0.8, 1.8, 0.8))
		var terrain_node = get_node(terrain)
		var prev_motion = motion
		motion = boxMover.get_motion(get_translation(), motion, aabb, terrain_node)
		isOnFloor(motion, prev_motion)
		global_translate(motion)
		
	assert(delta > 0)
	velocity = motion / delta

#is on floor
func isOnFloor(motion : Vector3, prev_motion : Vector3):
	if abs(motion.y) < 0.001:
		if prev_motion.y < 0.001:
			_grounded = true
	else:
		_grounded = false

#get voxel
func getPointVoxel(object: Object) -> Vector3:
	var origin = object.get_global_transform().origin
	var forward = -object.get_transform().basis.z.normalized()
	var hit = _terrain_tool.raycast(origin, forward, 1)
	return hit
	

#camera rotation
func cameraZoom(delta: float) -> void:
	#clamp zoom
	var new_zoom = clamp(
		camera.translation.z + zoomSpeed * delta * _zoomDir,
		minZoom,
		maxZoom
	)
	#move zoom
	camera.translation.z = new_zoom

	#damp the zooming
	_zoomDir *= zoomSpeedDamp
	if abs(_zoomDir) <= 0.0001:
		_zoomDir = 0

