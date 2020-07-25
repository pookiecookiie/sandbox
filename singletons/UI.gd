extends Node


var ChatScene = preload("res://scenes/Chat/Chat.tscn")
var Chat

var settings = {
	"DEBUG": true,
}

func _ready():
	get_node("/root/UI").add_child(ChatScene.instance())
	Chat = get_node("/root/UI/Chat")


# Will log a message as DEBUG so will only be visible if UI>SETTINGS>DEBUG is true
func debug(message:String, from:String=""):
	if !Chat or !settings.DEBUG:
		print("Debug: Chat not ready " + from)
		return
	
	# I want to save this to a file at some point
	if !from.empty():
		Chat.Messages.debug(message, from)
	else:
		Chat.Messages.debug(message)


func debug_success(message:String, from:String=""):
	if !Chat or !settings.DEBUG:
		print("Debug success: Chat not ready " + from)
		return
	
	# I want to save this to a file at some point
	if !from.empty():
		Chat.Messages.debug_success(message, from)
	else:
		Chat.Messages.debug_success(message)


func debug_error(message:String, from:String=""):
	if !Chat or !settings.DEBUG:
		print("Debug Error: Chat not ready "  + from)
		return
	
	# I want to save this to a file at some point
	if !from.empty():
		Chat.Messages.debug_error(message, from)
	else:
		Chat.Messages.debug_error(message)


func info(message:String, from:String=""):
	if !Chat:
		print("Info: Chat not ready " + from)
		return
	
	if !from.empty():
		Chat.Messages.info(message, from)
	else:
		Chat.Messages.info(message)


func success(message:String, from:String=""):
	if !Chat:
		print("Success: Chat not ready "  + from)
		return
	
	if !from.empty():
		Chat.Messages.success(message, from)
	else:
		Chat.Messages.success(message)


func error(message:String, from:String=""):
	if !Chat:
		print("Error: Chat not ready " + from)
		return
			
	if !from.empty():
		Chat.Messages.error(message, from)
	else:
		Chat.Messages.error(message)
