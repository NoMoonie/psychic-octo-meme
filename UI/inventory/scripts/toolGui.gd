extends Control

var slot_script = preload("res://UI/inventory/scripts/toolSlot.gd")
var slot_item = preload("res://UI/inventory/inv_item.tscn")
var init = false

onready var grid = $background/GridContainer
onready var mouse_slot = get_parent().get_node("Inventory/mouse_slot")

func _ready():
	GameManeger.connect("player_init", self, "_on_player_init")
	
func _on_player_init(player):
	player.toolbar.connect("inventory_changed", self, "_on_player_inventory_changed")

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
			#adding script and item image to the slot
			var _item = slot_item.instance()
			slots.add_child(_item)
			slots.set_script(slot_script)
			if item != null:
				slots.item = item
			else:
				pass
			slots.slot_index = index
			grid.add_child(slots)
			index += 1
		
		for inv_slots in grid.get_children():
			inv_slots.connect("gui_input", self, "slots_gui_input", [inv_slots])


func slots_gui_input(event: InputEvent, slot: toolslot):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			if mouse_slot.item != null:
				if slot.item == null:
					#put into empty slot
					slot.putInToSlot(mouse_slot.item, slot.slot_index)
					mouse_slot.pickFromSlot()
				else:
					if slot.item.item_referance.stackable and slot.item.item_referance.id == mouse_slot.item.item_referance.id:
						#get the stacks
						var max_stack_size = slot.item.item_referance.max_stack_size
						var slot_item_quantity = slot.item.quantity
						var mouse_item_quantity = mouse_slot.item.quantity
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
		elif event.button_index == BUTTON_RIGHT and event.pressed:
			if mouse_slot.item != null:
				#if mouse slot it not empty 
				if slot.item == null:
					
					var mouse_stack = mouse_slot.item.quantity - 1
					if mouse_stack >= 0:
						slot.addInToSlot(1, slot.slot_index, mouse_slot.item)
						if mouse_stack == 0:
							mouse_slot.pickFromSlot()
						else:
							mouse_slot.addRemainder(mouse_stack)
				else:
					if slot.item.item_referance.stackable and slot.item.item_referance.id == mouse_slot.item.item_referance.id:
						var max_stack_size = slot.item.item_referance.max_stack_size
						var slot_item_quantity = slot.item.quantity
						var mouse_item_quantity = mouse_slot.item.quantity
						if slot_item_quantity < max_stack_size:
							#add item one by one
							var slot_stack = slot_item_quantity + 1
							var mouse_stack = mouse_item_quantity - 1
							if mouse_stack >= 0:
								slot.addInToSlot(slot_stack, slot.slot_index, slot.item)
								if mouse_stack == 0:
									mouse_slot.pickFromSlot()
								else:
									mouse_slot.addRemainder(mouse_stack)
			else:
				if slot.item == null:
					pass
				else:
					if slot.item.item_referance.stackable:
						var slot_item_quantity = slot.item.quantity
						var split_stack = slot_item_quantity % 2
						mouse_slot.set_global_position(get_global_mouse_position())
						if slot_item_quantity > 1:
							if split_stack == 1:
								split_stack = slot_item_quantity / 2
								var floor_ = int(floor(split_stack))
								slot.addInToSlot(floor_ + 1, slot.slot_index, slot.item)
								mouse_slot.addItemRemainder(floor_, slot.item)
							else:
								split_stack = slot_item_quantity / 2
								slot.addInToSlot(split_stack, slot.slot_index, slot.item)
								mouse_slot.addItemRemainder(split_stack, slot.item)
						
func _input(_event):
	if 	mouse_slot.item:
		mouse_slot.set_global_position(get_global_mouse_position())
	else:
		pass
