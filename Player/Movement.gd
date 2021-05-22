extends KinematicBody

#player movement
export(int, 1, 50) var walkSpeed : int = 10
export(int, 1, 100) var spintSpeed : int = 15
var movementSpeed : int = 0
export var acceleration : float = 15
export var air_acceleration : float = 5
export(float, 0.1, 1, 0.01) var gravity : float = 0.98
export var max_terminal_velocity : float = 54
export var jump_power : float = 20
export var rotation_speed : float = 7
export var Flying : bool = false

#box mover from godotvoxel
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

#camera and player animator
onready var camera_pivot = $camRoot
onready var camera = $camRoot/h/v/Camera
onready var animPlayer = $playerModel/AnimationPlayer


func _input(event):
	if event.is_action_pressed("camera_zoom_in"):
		_zoomDir = -1
	if event.is_action_pressed("camera_zoom_out"):
		_zoomDir = 1

func _physics_process(delta):
	cameraZoom(delta)
	handle_movement(delta)

func handle_movement(delta):
	var direction = Vector3()
	var h_rot = $camRoot/h.global_transform.basis.get_euler().y


	#get direction moving in
	direction = Vector3(Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
	0,
	Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward")).rotated(Vector3.UP, h_rot).normalized()
	#rotate and animate if moving
	if direction != Vector3.ZERO:
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

	#gravity
	var accel = acceleration if is_on_floor() else air_acceleration
	velocity = velocity.linear_interpolate(direction * movementSpeed, accel * delta)

	#check if on floor
	if is_on_floor():
		y_velocity = -0.01
	else:
		#animPlayer.play("jump")
		y_velocity = clamp(y_velocity - gravity, -max_terminal_velocity, max_terminal_velocity)

	#jump and jump up if close to a wall
	if is_on_wall():
		y_velocity = 10

		#var pos = translation.y
		#var newPos = round(pos) + 1.0
		#translation.y = newPos
		#print(round(pos))
	if Input.is_action_just_pressed("jump") and is_on_floor() and !Flying:
		y_velocity = jump_power
	elif Input.is_action_pressed("jump") and Flying:
		y_velocity = jump_power
	elif Input.is_action_pressed("sprint") and Flying:
		y_velocity = -jump_power
	elif Flying:
		y_velocity = 0

	velocity.y = y_velocity

	#move
	#if has_node(terrain):
	#	var aabb = AABB(Vector3(-0.4, 0, -0.4), Vector3(0.8, 1.8, 0.8))
	#	var terrain_node = get_node(terrain)
	#	velocity = boxMover.get_motion(get_translation(), velocity, aabb, terrain_node)
	#	global_translate(velocity)

	velocity = move_and_slide(velocity, Vector3.UP)

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

