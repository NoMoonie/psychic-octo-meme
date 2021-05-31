extends Control

var slot_script = preload("./invSlot.gd")
var bg_style = preload("../../assets/styles/BgStyles/default_bg_inventory.stylebox")
var init = false

onready var grid = $background/GridContainer
onready var background = $background
onready var mouse_slot = get_parent().get_node("mouseSlot")

func _ready():
	background.set("custom_styles/panel", bg_style)
	GameManeger.connect("player_init", self, "_on_player_init")
	
func _on_player_init(player):
	player.inventory.connect("inventory_changed", self, "_on_player_inventory_changed")

func _on_player_inventory_changed(inv):
	if not init:
		init = true	
		for n in grid.get_children():
			n.queue_free()
		var index = 0
		for item in inv.get_items():
			#create panel and textureReact
			var slots = Panel.new()
			#size of the slot and the item image
			slots.rect_min_size = Vector2(40, 40)
			slots.rect_scale = Vector2(0.5, 0.5)
			slots.set_script(slot_script)
			if item != null:
				slots.item = item
			slots.slot_index = index
			grid.add_child(slots)
			index += 1
		
		for inv_slots in grid.get_children():
			inv_slots.connect("gui_input", self, "slots_gui_input", [inv_slots])

func slots_gui_input(event: InputEvent, slot: inventory_slot):
	slot.input(event, slot, mouse_slot)

func _input(_event):
	if 	mouse_slot.item:
		mouse_slot.set_global_position(get_global_mouse_position())
	else:
		pass
