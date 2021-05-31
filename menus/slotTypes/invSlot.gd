extends slot
class_name inventory_slot

func _ready():
	style = preload("res://menus/assets/styles/SlotStyles/default_style.stylebox")
	style_empty = preload("res://menus/assets/styles/SlotStyles/empty_style.stylebox")
	itemImg = $container/item
	label = $container/Label
	node = get_tree().get_root().get_node("/root/World/Player")
	inventory = "inventory"
	node.get(inventory).connect("inventory_changed", self, "_inv_change")
	refresh()
