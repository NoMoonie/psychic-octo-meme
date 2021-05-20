extends Spatial

var cameraRot_h = 0
var cameraRot_v = 0
export(float, 0.01, 1) var mouse_sensitivity : float = 0.1
export(float, -90, 0) var min_pitch : float = -90
export(float, 0, 90) var max_pitch : float = 90

func _ready():
	pass
	#$h/v/Camera.add_exception(get_parent())

func _input(event):
	if event is InputEventMouseMotion:
		cameraRot_h += -event.relative.x * mouse_sensitivity
		cameraRot_v += event.relative.y * mouse_sensitivity


func _process(_delta):
	
	cameraRot_v = clamp(cameraRot_v, min_pitch, max_pitch)
	
	$h.rotation_degrees.y = cameraRot_h
	$h/v.rotation_degrees.x = cameraRot_v
