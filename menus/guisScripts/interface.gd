extends Control

onready var mouse_slot = $mouseSlot

func _notification(what):
	match what:
		NOTIFICATION_MOUSE_ENTER:
			mouse_slot.in_inventory = false
		NOTIFICATION_MOUSE_EXIT:
			mouse_slot.in_inventory = true
			
func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			mouse_slot.dropStack()
		elif event.button_index == BUTTON_RIGHT and event.pressed:
			mouse_slot.dropItem()
