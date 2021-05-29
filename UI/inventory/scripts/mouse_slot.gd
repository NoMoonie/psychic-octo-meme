extends Node2D
class_name mouse_slot

var slot_index = 6969
var item = null

onready var itemImg = $container/item
onready var label = $container/Label

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
	item = new_item
	refresh()
	
func addItemRemainder(quantity, _item):
	var new_item = {
			item_referance = _item.item_referance,
			quantity = quantity
		}
	item = new_item
	refresh()

func refresh():
	if item != null:
		if item.quantity == 1:
			label.text = ""
		else:
			label.text = String(item.quantity)
		itemImg.texture = item.item_referance.texture
	else:
		label.text = ""
		itemImg.texture = null
	
	
