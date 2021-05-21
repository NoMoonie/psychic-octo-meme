extends KinematicBody


export(int, 0.1, 1, 0.01) var walkSpeed : int = 1
var movementSpeed : int = 0
export var acceleration : float = 15
export var air_acceleration : float = 5
export(float, 0.1, 1, 0.01) var gravity : float = 0.98
export var max_terminal_velocity : float = 54
export var jump_power : float = 15
export var rotation_speed : float = 7

var direction : Vector3
#move vector
var velocity : Vector3
var y_velocity : float

enum states{
	idle,
	alert,
	stunned,
	attack
}

var target
var state = states.idle

onready var eyes = $eyes

#alert range
func _on_sightrange_body_entered(body):
	if body.is_in_group("Player"):
		print("alert")
		state = states.alert
		target = body
func _on_sightrange_body_exited(_body):
	print("not alert")
	state = states.idle
	target = null

#attack range
func _on_Area_body_entered(body):
	if body.is_in_group("Player"):
		state = states.attack

func _on_Area_body_exited(_body):
	state = states.alert


func _physics_process(delta):
	#state
	match state:
		states.idle:
			direction = Vector3(0, 0, 0)
		states.alert:
			direction = target.translation - translation
		states.stunned:
			pass
		states.attack:
			direction = Vector3()
	#move
	handelMovment(delta)





func handelMovment(delta):

	if direction != Vector3.ZERO:
		#eyes.rotation.y = lerp_angle(eyes.rotation.y, atan2(direction.x, direction.z), delta * rotation_speed)
		eyes.look_at(target.global_transform.origin, Vector3.UP)
		rotate_y(deg2rad(eyes.rotation.y * rotation_speed))
		#new branch
	if is_on_floor():
		y_velocity = -0.01
	else:
		#animPlayer.play("jump")
		y_velocity = clamp(y_velocity - gravity, -max_terminal_velocity, max_terminal_velocity)
	if is_on_wall():
		y_velocity = jump_power
	velocity.y = y_velocity

	var accel = acceleration if is_on_floor() else air_acceleration
	velocity = velocity.linear_interpolate(direction * walkSpeed, accel * delta)

	velocity = move_and_slide(velocity, Vector3.UP)
