extends Node

signal player_init

var player

func _input(event):
	if event is InputEventKey and Input.is_key_pressed(KEY_L):
		player.inventory.add_item("Axe", 16)
	if event is InputEventKey and Input.is_key_pressed(KEY_J):
		player.inventory.clear_inventory()
		
func _process(_delta):
	if not player:
		init_player()
		return

func init_player():
	player = get_parent().get_node("World/Player")
	if not player:
		return
		
	emit_signal("player_init", player)
	
	player.inventory.connect("inventory_changed", self, "_on_player_inventory_changed")
	player.toolbar.connect("inventory_changed", self, "_toolbar_change")
	var existing_inv = load("user://inventory.tres")
	var existing_toolbar = load("user://toolbar.tres")
	if existing_inv and existing_toolbar:
		player.inventory.set_items(existing_inv.get_items())
		player.toolbar.set_items(existing_toolbar.get_items())
		#player.inventory.add_item_to_index("Mushroom", 20, 1)
		#player.toolbar.add_item_to_index("Grass", 20, 1)
	else:
		player.inventory.add_item("Grass", 99)
		player.toolbar.add_item("Axe", 1)
		pass
	
func _on_player_inventory_changed(inv):
	var res = ResourceSaver.save("user://inventory.tres", inv)
	if res == 0:
		print("File saved! inv")
	else:
		 print("File not saved!")

func _toolbar_change(inv):
	var res = ResourceSaver.save("user://toolbar.tres", inv)
	if res == 0:
		print("File saved! toobar")
	else:
		 print("File not saved!")
