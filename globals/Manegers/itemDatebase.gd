extends Node

var items = Array()
var _folder = "../../menus/Resource/items"

func _ready():
	var directory = Directory.new()
	directory.open("res://menus/Resource/items/")
	directory.list_dir_begin()
	
	var fileName = directory.get_next()
	while(fileName):
		if not directory.current_is_dir():
			items.append(load("res://menus/Resource/items/%s" %fileName))
		fileName = directory.get_next()
	

func get_item(item_name):
	for i in items:
		if i.name == item_name:
			return i
		
	return null
