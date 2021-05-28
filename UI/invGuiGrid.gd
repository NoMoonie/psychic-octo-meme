extends Control

var slot = preload("res://UI/slot.gd")
var init = false
var holding_item = null

onready var grid = $background/GridContainer
onready var mouse_slot = $mouse_slot

func _ready():
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
			var texture_rect = TextureRect.new()
			var number = Label.new()
			#size of the slot and the item image
			slots.rect_min_size = Vector2(40, 40)
			texture_rect.rect_scale = Vector2(0.5, 0.5)
			texture_rect.name = "item"
			number.name = "quantity"
			#adding script and item image to the slot
			slots.add_child(texture_rect)
			slots.add_child(number)
			slots.set_script(slot)
			if item != null:
				slots.item = item
				number.text = String(item.quantity)
				#mesh.texture = item.item_referance.texture
				#item_label.text = "%s x%d" % [item.item_referance.name, item.quantity]
			else:
				pass
			slots.slot_index = index
			grid.add_child(slots)
			index += 1
		
		for inv_slots in grid.get_children():
			inv_slots.connect("gui_input", self, "slots_gui_input", [inv_slots])


func slots_gui_input(event: InputEvent, slot: slot):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			print("slot index:"+String(slot.slot_index))
			if mouse_slot.item != null:
				if !slot.item:
					#put into empty slot
					slot.putInToSlot(mouse_slot.item, slot.slot_index)
					mouse_slot.pickFromSlot()
				else:
					if slot.item.item_referance.stackable and slot.item.item_referance.id == mouse_slot.item.item_referance.id:
						#get the stacks
						var max_stack_size = slot.item.item_referance.max_stack_size
						var slot_item_quantity = slot.item.quantity
						var mouse_item_quantity = mouse_slot.item.quantity
						var remaining_quantity = mouse_item_quantity
						#check if ether off the stack are full
						if slot_item_quantity < max_stack_size and mouse_item_quantity < max_stack_size:
							#add the stack together
							var current_stack = slot_item_quantity + mouse_item_quantity
							#check it is larger than max_stack
							if current_stack > max_stack_size:
								#get the remainder and the full stack
								var remainder = current_stack - max_stack_size
								var new_stack = current_stack - remainder
								#add the stacks
								slot.addInToSlot(new_stack, slot.slot_index, slot.item)
								mouse_slot.addRemainder(remainder)
							else:
								#add stacks together 
								slot.addInToSlot(current_stack, slot.slot_index, slot.item)
								mouse_slot.pickFromSlot()
						else:
							#swap stacks
							var temp_item = slot.item
							slot.putInToSlot(mouse_slot.item, slot.slot_index)
							mouse_slot.putInToSlot(temp_item)
					else:
						#swap items
						var temp_item = slot.item
						slot.putInToSlot(mouse_slot.item, slot.slot_index)
						mouse_slot.putInToSlot(temp_item)
			elif slot.item:
				#pickup item from slot
				mouse_slot.set_global_position(get_global_mouse_position())
				mouse_slot.putInToSlot(slot.item)
				slot.pickFromSlot()
			

func _input(event):
	if 	mouse_slot.item:
		#mouse_slot.show()
		mouse_slot.set_global_position(get_global_mouse_position())
	else:
		#mouse_slot.hide()
		pass