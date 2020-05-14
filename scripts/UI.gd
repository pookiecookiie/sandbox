extends Node

onready var Chat = get_node("/root/main/ui/Chat")

func _input(event):
	if !Chat:
		return
	
	if event.is_action_pressed("open_chat") and !Chat.visible:
		Chat.open()
	
	if event.is_action_pressed("close_chat") and Chat.visible:
		Chat.close()
	
	if event.is_action_pressed("clear_console"):
		Chat.clear()


