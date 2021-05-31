extends Control
class_name gui

var bg_style = ""

onready var grid = $background/GridContainer
onready var background = $background
onready var mouse_slot = get_parent().get_node("mouseSlot")

func _ready():
	GameManeger.connect("player_init", self, "_on_player_init")
	
func _on_player_init(player):
	var index = 0
	for n in grid.get_children():
		n.slot_index = index
		n.connect("gui_input", self, "slots_gui_input", [n])
		index += 1

func slots_gui_input(event: InputEvent, slot):
	slot.input(event, slot, mouse_slot)

func _input(_event):
	if 	mouse_slot.item:
		mouse_slot.set_global_position(get_global_mouse_position())
	else:
		pass

func refresh():
	background.set("custom_styles/panel", bg_style)
