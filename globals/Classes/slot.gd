extends Panel
class_name slot

var style : StyleBoxTexture = null
var style_empty : StyleBoxTexture = null
var style_hover : StyleBoxTexture = null

var slot_index : int = 0
var item = null

#item image
var itemImg = null
var label = null
#get init inventory
var node = null
var inventory : String = ""

func _ready():
	mouse_filter = MOUSE_FILTER_PASS
	var slot_item = load("res://menus/assets/scenes/inv_item.tscn").instance()
	add_child(slot_item)
	
func _inv_change(_inv):
	if !item:
		var new_item = node.get(inventory).get_item(slot_index)
		if new_item:
			item = new_item
			print("---------------------------------------------")
			print("slot_index: "+ str(slot_index))
			print(new_item.item_referance.name)
			print("---------------------------------------------")
	else:
		var new_item = node.get(inventory).get_item(slot_index)
		if !new_item:
			item = new_item
	refresh()

func pickFromSlot():
	item = null
	node.get(inventory).remove_item(slot_index)
	refresh()
	
func putInToSlot(mouse_item, index):
	item = mouse_item
	node.get(inventory).move_item_to_index(mouse_item, index)
	refresh()
	
func addInToSlot(quantity, index, item_ref):
	var new_item = node.get(inventory).add_quantity(index, quantity, item_ref)
	item = new_item
	refresh()

func refresh():
	if item != null:
		if item.quantity == 1:
			label.text = ""
		else:
			label.text = String(item.quantity)
		itemImg.texture = item.item_referance.texture
		set("custom_styles/panel", style)
	else:
		label.text = ""
		itemImg.texture = null
		set("custom_styles/panel", style_empty)
		
func _notification(what):
	match what:
		NOTIFICATION_MOUSE_ENTER:
			#print(slot_index)
			#print("in")
			pass
		NOTIFICATION_MOUSE_EXIT:
			#print("out")
			pass

func input(event, slot, mouse_slot):
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
