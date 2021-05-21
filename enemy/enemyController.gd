extends KinematicBody


export(int, 1, 50) var walkSpeed : int = 5
export(int, 1, 100) var spintSpeed : int = 15
var movementSpeed : int = 0
export var acceleration : float = 15
export var air_acceleration : float = 5
export(float, 0.1, 1, 0.01) var gravity : float = 0.98
export var max_terminal_velocity : float = 54
export var jump_power : float = 20
export var rotation_speed : float = 7 

var direction : Vector3
#move vector
var velocity : Vector3
var y_velocity : float

enum {
	idle,
	alert,
	stunned
}

var target
var target_follow = false
var state = idle


onready var eyes = $eyes


func _on_sightrange_body_entered(body):
	if body.is_in_group("Player"):
		print("alert")
		state = alert
		target = body


func _on_sightrange_body_exited(body):
	print("not alert")
	state = idle
	target = null


func _physics_process(delta):
	match state:
		idle:
			direction = Vector3(0, 0, 0)
		alert:
			#eyes.look_at(target.global_transform.origin, Vector3.UP)
			direction = Vector3(target.transform.origin - transform.origin).normalized()
			target_follow = true
			pass
		stunned:
			pass
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
		
	velocity.y = y_velocity
	
	var accel = acceleration if is_on_floor() else air_acceleration
	velocity = velocity.linear_interpolate(direction * movementSpeed, accel * delta)
	
	velocity = move_and_slide(velocity, Vector3.UP)
