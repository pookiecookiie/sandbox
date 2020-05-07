extends Node

onready var Chat = get_node("/root/main/ui/Chat")
onready var Lobby = get_node("/root/main/ui/Lobby")

func _input(event):
	if event.is_action_pressed("ui_accept") and !Chat.visible:
		Chat.toggle()
	
	if event.is_action_pressed("ui_cancel") and Chat.visible:
		Chat.toggle()
	
	if event.is_action_pressed("clear_console"):
		Chat.clear_log()


func has_open_window(windows:Dictionary):
	var has_open_window = false
	
	for window in windows.values():
		if window.visible:
			has_open_window = true
			break
	
	return has_open_window

