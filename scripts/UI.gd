extends Node

onready var Chat = get_node("/root/main/ui/Chat")

func _input(event):
	if event.is_action_pressed("open_chat") and !Chat.visible:
		Chat.open()
	
	if event.is_action_pressed("close_chat") and Chat.visible:
		Chat.close()
	
	if event.is_action_pressed("clear_console"):
		Chat.clear_log()


func has_open_window(windows:Dictionary):
	var has_open_window = false
	
	for window in windows.values():
		if window.visible:
			has_open_window = true
			break
	
	return has_open_window

