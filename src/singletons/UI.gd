extends Node

onready var Chat

func _ready():
	pass


func _input(event):
	if !Chat:
		return
	
	if event.is_action_pressed("open_chat") and !Chat.visible:
		Chat.open()
	
	if event.is_action_pressed("close_chat") and Chat.visible:
		Chat.close()
	
	if event.is_action_pressed("clear_console"):
		Chat.clear_log()


