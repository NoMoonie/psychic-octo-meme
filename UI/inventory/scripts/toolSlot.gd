extends Panel
class_name toolslot

var style : StyleBoxTexture = preload("res://UI/styles/stylebox/default_style.stylebox")
var style_empty : StyleBoxTexture = preload("res://UI/styles/stylebox/empty_style.stylebox")
var style_hover : StyleBoxTexture = preload("res://UI/styles/stylebox/hover_style.stylebox")

var slot_index = 0
var item = null

onready var itemImg = $container/item
onready var label = $container/Label
onready var playerset = get_tree().get_root().get_node("/root/World/Player")

func _ready():
	refresh()
	playerset.toolbar.connect("inventory_changed", self, "_inv_change")
	 
func _inv_change(_inv):
	if !item:
		var new_item = _inv.get_item(slot_index)
		if new_item:
			item = new_item
			print("---------------------------------------------")
			print("slot_index: "+ str(slot_index))
			print(new_item.item_referance.name)
			print("---------------------------------------------")
	else:
		var new_item = _inv.get_item(slot_index)
		if !new_item:
			item = new_item
	refresh()

func pickFromSlot():
	item = null
	playerset.toolbar.remove_item(slot_index)
	refresh()
	
func putInToSlot(mouse_item, index):
	item = mouse_item
	playerset.toolbar.move_item_to_index(mouse_item, index)
	refresh()
	
func addInToSlot(quantity, index, item_ref):
	var new_item = playerset.toolbar.add_quantity(index, quantity, item_ref)
	print(new_item)
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
		
	
#func _notification(what):
#	match what:
#		NOTIFICATION_MOUSE_ENTER:
#			set("custom_styles/panel", style_hover)
#		NOTIFICATION_MOUSE_EXIT:
#			if item != null:
#				set("custom_styles/panel", style)
#			else:	
#				set("custom_styles/panel", style_empty)
	
