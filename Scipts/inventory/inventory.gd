extends Resource
class_name Inventory

signal inventory_changed

export var _items = Array() setget set_items, get_items


func set_items(new_items):
	_items = new_items
	emit_signal("inventory_changed", self)
	
func get_items():
	return _items

func get_item(index):
	return _items[index]

func add_item(item_name, quantity):
	if quantity <= 0:
		print("can't add negative number of items")
		return
		
	var item = ItemDatebase.get_item(item_name)
	if not item:
		print("Could not find item")
		return
		
	var remaining_quantity = quantity
	var max_stack_size = item.max_stack_size if item.stackable else 1
	
	if item.stackable:
		for i in range(_items.size()):
			
			if remaining_quantity == 0:
				break
			var inventory_item = _items[i]
			
			if inventory_item == null:
				continue
			
			if inventory_item.item_referance.name != item.name:
				continue
			
			if inventory_item.quantity < max_stack_size:
				var original_quantity = inventory_item.quantity
				inventory_item.quantity = min(original_quantity + remaining_quantity, max_stack_size)
				remaining_quantity -= inventory_item.quantity - original_quantity
			
	while remaining_quantity > 0:
		var new_item = {
			item_referance = item,
			quantity = min(remaining_quantity, max_stack_size)
		}
		for i in range(_items.size()):
			if _items[i] == null:
				_items[i] = new_item
				break
		remaining_quantity -= new_item.quantity
	
	emit_signal("inventory_changed", self)

func add_item_to_index(item_name, quantity, index):
	var item = ItemDatebase.get_item(item_name)
	var remaining_quantity = quantity
	var max_stack_size = item.max_stack_size if item.stackable else 1
	while remaining_quantity > 0:
		var new_item = {
			item_referance = item,
			quantity = min(remaining_quantity, max_stack_size)
		}
		_items[index] = new_item
		remaining_quantity -= new_item.quantity
	emit_signal("inventory_changed", self)

func remove_item(index):
	_items[index] = null
	emit_signal("inventory_changed", self)

func move_item_to_index(item, index):
	_items[index] = item
	emit_signal("inventory_changed", self)

func add_quantity(index, quantity, item) -> Dictionary:
	var new_item = {
			item_referance = item.item_referance,
			quantity = quantity
		}
	_items[index] = new_item
	emit_signal("inventory_changed", self)
	return new_item

func clear_inventory():
	for i in range(_items.size()):
		_items[i] = null 
	emit_signal("inventory_changed", self)
	
func create_resourse(filename:String, size:int):
	pass

