extends Node

signal player_init

var player

func _input(event):
	if event is InputEventKey and Input.is_key_pressed(KEY_L):
		player.inventory.add_item("Axe", 1)
	if event is InputEventKey and Input.is_key_pressed(KEY_K):
		player.inventory.add_item("Grass", 100)
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
	player.equipment.connect("inventory_changed", self, "_equipment_change")
	var existing_inv = load("user://inventory.tres")
	var existing_toolbar = load("user://toolbar.tres")
	var existing_equipment = load("user://equipment.tres")
	if existing_inv and existing_toolbar and existing_equipment:
		player.inventory.set_items(existing_inv.get_items())
		player.toolbar.set_items(existing_toolbar.get_items())
		player.equipment.set_items(existing_equipment.get_items())
	else:
		player.inventory.save()
		player.toolbar.save()
		player.equipment.save()
	
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
		
func _equipment_change(inv):
	var res = ResourceSaver.save("user://equipment.tres", inv)
	if res == 0:
		print("File saved! equipment")
	else:
		 print("File not saved!")
	
