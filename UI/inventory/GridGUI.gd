extends Control
class_name gridgui
	
static func create_grid(container, inventory, slot_item, slot_script):
	for n in container.get_children():
		n.queue_free()
	var index = 0
	for item in inventory.get_items():
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
		container.add_child(slots)
		index += 1
		
func left_mouse(slot, mouse_slot):
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
		
	

