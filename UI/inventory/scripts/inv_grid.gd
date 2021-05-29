extends GridContainer

var slot = preload("res://slot.gd")
var init = false
var holding_item = null

func _ready():
	GameManeger.connect("player_init", self, "_on_player_init")
	
func _on_player_init(player):
	player.inventory.connect("inventory_changed", self, "_on_player_inventory_changed")

func _on_player_inventory_changed(inv):
	if not init:
		init = true
		for n in get_children():
			n.queue_free()
		#print(inv.get_item(3))
		var index : int = 0
		for item in inv.get_items():
			#create panel and textureReact
			var slots = Panel.new()
			var texture_rect = TextureRect.new()
			#size of the slot and the item image
			slots.rect_min_size = Vector2(40, 40)
			texture_rect.rect_scale = Vector2(0.5, 0.5)
			texture_rect.name = "item"
			#adding script and item image to the slot
			slots.add_child(texture_rect)
			slots.set_script(slot)
			if item != null:
				slots._inv = inv
				slots.item = item
				slots.slot_index = index
				#mesh.texture = item.item_referance.texture
				#item_label.text = "%s x%d" % [item.item_referance.name, item.quantity]
			else:
				#item_label.text = "non"
				pass
			add_child(slots)
			index += 1
			
		for inv_slots in get_children():
			inv_slots.connect("gui_input", self, "slots_gui_input", [inv_slots])


func slots_gui_input(event: InputEvent, slot: slot):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			if holding_item != null:
				if !slot.item:
					slot.putInToSlot(slot.item, slot.item)
				else:
					pass
			elif slot.item:
				holding_item = slot.item
				slot.pickFromSlot()
			
func _input(event):
	pass
