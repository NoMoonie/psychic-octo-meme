extends Node2D
class_name mouse_slot

var slot_index = 6969
var item = null
export var in_inventory : bool

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
	
func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			if item:
				if !in_inventory:
					var player = get_tree().get_root().get_node("/root/World/Player")
					var _item_inst = load("res://Assets/items/item.tscn").instance()
					_item_inst.global_transform = player.global_transform
					_item_inst.item = item
					_item_inst.terrain = "../VoxelTerrain"
					var root = get_tree().get_root().get_node("/root/World").add_child(_item_inst)
					pickFromSlot()
