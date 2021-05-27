extends Node

signal player_init

var player

func _input(event):
	if event is InputEventKey and Input.is_key_pressed(KEY_L):
		player.inventory.add_item_to_index("Mushroom", 20, 0)
func _process(delta):
	if not player:
		init_player()
		return

func init_player():
	player = get_parent().get_node("World/Player")
	if not player:
		return
		
	emit_signal("player_init", player)
	
	player.inventory.connect("inventory_changed", self, "_on_player_inventory_changed")
	
	var existing_inv = load("user://inventory.tres")
	if existing_inv:
		player.inventory.set_items(existing_inv.get_items())
		#for i in range(0, 20):
			#player.inventory.add_item_to_index("Mushroom", 23, i)
		#player.inventory.add_item_to_index("Mushroom", 20, 1)
	else:
		#player.inventory.add_item_to_index("Mushroom", 23, 0)
		pass
	
func _on_player_inventory_changed(inv):
	var res = ResourceSaver.save("user://inventory.tres", inv)
	if res == 0:
		print("File saved!")
	else:
		 print("File not saved!")
		
