extends Node

onready var ChatScene = preload("res://scenes/ui/Chat/Chat.tscn")

func _input(event):
	pass


func has_open_window(windows:Dictionary):
	var has_open_window = false
	
	for window in windows.values():
		if window.visible:
			has_open_window = true
			break
	
	return has_open_window
