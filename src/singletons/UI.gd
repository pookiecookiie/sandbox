extends Node

onready var Chat = get_node("/root/Chat")


func _input(event):
	# FIXME: This is not ideal, this UI handling events for the chat
	if !Chat:
		return
	
	if event.is_action_pressed("open_chat") and !Chat.visible:
		Chat.open()
	
	if event.is_action_pressed("close_chat") and Chat.visible:
		Chat.close()
	
	if event.is_action_pressed("clear_console"):
		Chat.clear_log()


