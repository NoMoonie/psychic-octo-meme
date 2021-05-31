extends Spatial

var cameraRot_h = 0
var cameraRot_v = 0
export(float, 0.01, 1) var mouse_sensitivity : float = 0.1
export(float, -90, 0) var min_pitch : float = -90
export(float, 0, 90) var max_pitch : float = 90

func _ready():
	set_as_toplevel(true)
	#$h/v/Camera.add_exception(get_parent())

func _input(event):
	if Input.get_mouse_mode() != Input.MOUSE_MODE_VISIBLE:
		if event is InputEventMouseMotion:
			cameraRot_h += -event.relative.x * mouse_sensitivity
			cameraRot_v += event.relative.y * mouse_sensitivity


func _physics_process(_delta):
	var target = get_parent().translation
	
	cameraRot_v = clamp(cameraRot_v, min_pitch, max_pitch)
	global_transform.origin = Vector3(target.x, target.y, target.z)
	$h.rotation_degrees.y = cameraRot_h
	$h/v.rotation_degrees.x = cameraRot_v
