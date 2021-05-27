extends Panel
class_name slot

var slot_index = 0
var item = null

onready var itemImg = $item
onready var label = $quantity
onready var playerset = get_tree().get_root().get_node("/root/World/Player")

func _ready():
	refresh()
	playerset.inventory.connect("inventory_changed", self, "_inv_change")
	
func _inv_change(inv):
	#refresh()
	pass

func pickFromSlot():
	item = null
	playerset.inventory.remove_item(slot_index)
	refresh()
	
func putInToSlot(mouse_item, index):
	item = mouse_item
	playerset.inventory.move_item_to_index(mouse_item, index)
	refresh()
	
func addInToSlot(quantity, index, item_ref):
	var new_item = playerset.inventory.add_quantity(index, quantity, item_ref)
	print(new_item)
	item = new_item
	refresh()
	
func refresh():
	if item != null:
		label.text = String(item.quantity)
		itemImg.texture = item.item_referance.texture
	else:
		label.text = ""
		itemImg.texture = null
	
	
	
