extends Panel
class_name slot

var style_tex = preload("res://slot_style.png")
var style_empty_tex = preload("res://slot_style_empty.png")

var style : StyleBoxTexture = null
var style_empty : StyleBoxTexture = null

var slot_index = 0
var item = null

onready var itemImg = $item
onready var label = $quantity
onready var playerset = get_tree().get_root().get_node("/root/World/Player")

func _ready():
	style = StyleBoxTexture.new()
	style_empty = StyleBoxTexture.new()
	style.texture = style_tex
	style_empty.texture = style_empty_tex
	refresh()
	playerset.inventory.connect("inventory_changed", self, "_inv_change")
	
func _inv_change(inv):
	if !item:
		var new_item = playerset.inventory.get_item(slot_index)
		if new_item:
			item = new_item
			print("---------------------------------------------")
			print("slot_index: "+ str(slot_index))
			print(new_item.item_referance.name)
			print("---------------------------------------------")
	else:
		var new_item = playerset.inventory.get_item(slot_index)
		if !new_item:
			item = new_item
	refresh()

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
		set("custom_styles/panel", style)
	else:
		label.text = ""
		itemImg.texture = null
		set("custom_styles/panel", style_empty)
	
	
	
