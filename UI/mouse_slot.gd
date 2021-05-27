extends Node2D
class_name mouse_slot

var slot_index = 6969
var item = null

onready var itemImg = $item
onready var label = $Label

func _ready():
	refresh()


func pickFromSlot():
	item = null
	refresh()
	
func putInToSlot(_item):
	item = _item
	refresh()

func addRemainder(quantity):
	var new_item = {
			item_referance = item.item_referance,
			quantity = quantity
		}
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
	
	
