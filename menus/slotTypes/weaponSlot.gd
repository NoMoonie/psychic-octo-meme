extends slot
class_name weapon_slot

func _ready():
	style = preload("res://menus/assets/styles/SlotStyles/default_style.stylebox")
	style_empty = preload("res://menus/assets/styles/SlotStyles/empty_style.stylebox")
	itemImg = $container/item
	label = $container/Label
	node = get_tree().get_root().get_node("/root/World/Player")
	inventory = "equipment"
	node.get(inventory).connect("inventory_changed", self, "_inv_change")
	type = itemType.Weapon
	refresh()


func input(event, slot, mouse_slot):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			if mouse_slot.item != null:
				if !mouse_slot.item.item_referance.stackable and slot.type == mouse_slot.item.item_referance.type:
					if slot.item == null:
						slot.putInToSlot(mouse_slot.item, slot.slot_index)
						mouse_slot.pickFromSlot()
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
