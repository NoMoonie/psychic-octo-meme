extends Spatial

onready var invnode = $interface/Inventory
var inv_show = true;

func _init():
	VisualServer.set_debug_generate_wireframes(true)


func _ready():
	randomize()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(_delta):
	#### Update HUD
	$interface/UI/VBox/FPS.text = "FPS: " + String(Engine.get_frames_per_second())
	var pos = $Player.global_transform.origin
	$interface/UI/VBox/Position.text = "Position: (%.1f, %.1f, %.1f)" % [pos.x, pos.y, pos.z]

func _input(event):
	if event is InputEventKey and Input.is_key_pressed(KEY_P):
		var vp = get_viewport()
		vp.debug_draw = (vp.debug_draw + 1 ) % 4

	elif event is InputEventKey and Input.is_action_just_pressed("fullscreen"):
		OS.window_fullscreen = ! OS.window_fullscreen
	
	elif event is InputEventKey and Input.is_action_just_pressed("open_inventory"):
		inv_show = !inv_show
		if(inv_show):
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			invnode.show()
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			invnode.hide()

	elif event is InputEventKey and Input.is_action_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			pass
		else:
			pass
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

