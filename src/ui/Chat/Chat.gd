extends Control

# ==============================================================================
#
# Chat

#	This is a template for organizing parts of files.
#	Make sure to try to keep it consistent and organized so you don't fuck your-
#	self up anymore with organization and clutter on files.

# Nodes
onready var ChatLog = $VBox/TextBox
onready var InputLabel = $VBox/HBox/Player
onready var InputField = $VBox/HBox/Input


# Colors
const RED = "#F00"
const GREEN = "#0F0"
const BLUE = "#00F"
const YELLOW = "#FF0"
const PINK = "#F0F"
const BLACK = "#000"
const GREY = "#AAA"
const WHITE = "#FFF"

const DARK = "#363537"

const RAJAH = "#FCAB64"
const ORANGE_PEEL = "#FF9F1C"
const TIFFANY_BLUE = "#2EC4B6"
const CG_BLUE = "#2978A0"
const BEAU_BLUE = "#C6E0FF"
const SCREAMING_GREEN = "#6bf178"


const HELP = {
	"pages": [
		("\n========\n"+
		"    HELP    |\n"+
		"================================================================================\n\n"+
		"@ COMMANDS\n\n"+
		">    /help  >>  shows this help thing\n"+
		">    /say  [MESSAGE]  >>  logs a message '[message]' to the chat.\n"+
		">    /clear  >>  clears the chat.\n"+
		">    /history  >>  shows your typing history. (up to 25 messages or commands).\n"+
		">    /client  [IP]  [PORT]  [SERVER_KEY]  >>  creates a client.\n"+
		">    /auth  [EMAIL]  [PASSWORD]  [USERNAME]  >>  Registers or logs an existing user.\n"+
		">    /socket  start  >>  creates a socket from this client.\n"+
		">    /socket  create  channel  >>  creates a channel using this socket. (realtime chat)\n\n"+
		">    If you think a command is missing, or would like to add something yourself\n"+
		">    this project is opensource  >>  https://github.com/pookiecookiie/sandbox\n"+
		">    - the dev\n\n"+
		"================================================================================\n")
	]
}


var Types = {
	"none": null,
	"chat": {
		"name": "chat",
		"color": SCREAMING_GREEN,
		"owner_color": TIFFANY_BLUE, # Command or username label/TAG
		"text_color": WHITE,
		"text_bg_color": DARK,

	},
	"debug": {
		"name": "debug",
		"color": BLUE,
		"text_color": WHITE,
		"text_bg_color": DARK,
	},
	"server": {
		"name": "server",
		"color": PINK,
		"text_color": WHITE,
		"text_bg_color": DARK,
	},
	"info": {
		"name": "info",
		"color": BEAU_BLUE,
		"text_color": WHITE,
		"text_bg_color": DARK,
	},
	"help": {
		"name": "help",
		"color": CG_BLUE,
		"text_color": WHITE,
		"text_bg_color": DARK,
	},
	"command": {
		"name": "command",
		"color": ORANGE_PEEL,
		"text_color": WHITE,
		"text_bg_color": DARK,
	},
	"success": {
		"name": "success",
		"color": GREEN,
		"text_color": WHITE,
		"text_bg_color": DARK,
	},
	"warning": {
		"name": "warning",
		"color": YELLOW,
		"text_color": WHITE,
		"text_bg_color": DARK,
	},
	"error": {
		"name": "error",
		"color": RED,
		"text_color": WHITE,
		"text_bg_color": DARK,
	}
}


var Commands = {
	"none": null,
	"help": {
		"name": "help",
		"color": RAJAH,
		"command": funcref(self, "command_help")
	},
	
	"say": {
		"name": "say",
		"color": RAJAH,
		"command": funcref(self, "command_say")
	},
	
	"history": {
		"name": "history",
		"color": RAJAH,
		"command": funcref(self, "command_history")
	},
	
	"clear": {
		"name": "clear",
		"color": RAJAH,
		"command": funcref(self, "command_clear")
	},
	
	"auth":{
		"name": "auth",
		"color": RAJAH,
		"command": funcref(self, "command_auth")
	},
	
	"socket": {
		"name": "socket",
		"color": RAJAH,
		"command": funcref(self, "command_socket")
	},
	
	"client": {
		"name": "client",
		"color": RAJAH,
		"command": funcref(self, "command_client")
	},
	"match": {
		"name": "match",
		"color": RAJAH,
		"command": funcref(self, "command_match")
	}
}


var typing_history = {
	"now": 1,
	"history": [],
	"max_history": 25,
}


var username : String = "guest"



# Godot functions
func _ready():
# warning-ignore:return_value_discarded
	Network.connect("received_channel_message", self, "_receive_message")
	
	InputField.connect("text_entered", self, "_on_text_entered")
	
	InputLabel.text = "["+username+"]"
	
	ChatLog.scroll_following = true
	
	log_info("Type '/help' for help.")
	
	
#	log_error("EXAMPLE ERROR")
#	log_warning("EXAMPLE WARNING")
#	log_success("EXAMPLE SUCCESS")
#	log_help("EXAMPLE HELP")
#	log_server("EXAMPLE SERVER")
#	command_say(["EXAMPLE SAY"])


func _input(event:InputEvent):
	if event.is_action_pressed("open_chat"):
		InputField.grab_focus()
	
	
	if event.is_action_pressed("close_chat"):
		InputField.release_focus()
	
	
	# Go back on the typing history 
	if event.is_action_pressed("ui_up"):
		print("") # for some reason print is needed here? (or i'm crazy')
		_go_back_history()
	
	# Go forward on the typing history
	if event.is_action_pressed("ui_down"):
		print("") # for some reason print is needed here? (or i'm crazy')
		_go_forward_history()



# Public utils
func toggle()->void:
	self.visible = !self.visible


func open()->void:
	self.visible = true


func close()->void:
	self.visible = false


func clear()->void:
	self.ChatLog.bbcode_text = ""


func set_username(new)->void:
	username = new
	
	InputLabel.text = "["+username+"]"


func debug(text, type=Types.debug, command=Commands.none)->void:
	ChatLog.bbcode_text += "\n "
	
	if command:
		_add_label(type.name, type.color)
		_add_label(command.name, command.color, true)
	else:
		_add_label(type.name, type.color, true)
		
	_add_text(text, type.text_color)



# Private utils
func _add_history(text)->void:
	typing_history.history.append(text)
	typing_history.now = typing_history.history.size()
	
	if typing_history.history.size() > typing_history.max_history:
		typing_history.history.pop_front()

func _go_back_history():
	var previous = typing_history.now - 1
	if !previous < 0 and !typing_history.history.empty():
		typing_history.text = typing_history.history[previous]
		typing_history.now = previous

func _go_forward_history():
	var next = typing_history.now + 1
	if !next > typing_history.history.size()-1:
		InputField.text = typing_history.history[next]
		typing_history.now = next


func _get_prop_args(args)->Array:
	var prop_args = []
	
	for arg in args:
		if arg != args[0]:
			prop_args.append(arg)
	return prop_args



# Convenience for debugging and to give the user feedback
func log_help(args)->void:
	debug(args, Types.help)


func log_info(args)->void:
	debug(args, Types.info)


func log_server(args)->void:
	debug(args, Types.server)


func log_success(args)->void:
	debug(args, Types.success)


func log_warning(args)->void:
	debug(args, Types.warning)


func log_error(args)->void:
	debug(args, Types.error)



# Commands
func command_say(args:PoolStringArray)->void:
	debug(args.join(" "), Types.command, Commands.say)


func command_history(_args:PoolStringArray)->void:
	var history = typing_history.history
	debug("Your typing history: " + str(history), Types.info, Commands.history)
	


func command_clear(_args:PoolStringArray)->void:
	ChatLog.bbcode_text = ""
	log_info("Chat cleared!")


func command_help(_args:PoolStringArray)->void:
	log_help(HELP.pages[0])


func command_socket(args:PoolStringArray)->int:
	var prop = args[0]
	var prop_args = _get_prop_args(args)
	
	
	if prop.to_upper() == "START":
		Network.create_socket()
		return OK
	
	if prop.to_upper() == "CREATE":
		if prop_args[0].to_upper() == "CHANNEL":
			Network.create_channel()
			return OK
	
	if prop.to_upper() == "INFO":
		if !Network.current_channel:
			log_error("Not connected to a channel")
			return OK
	
	return 1


func command_auth(args:PoolStringArray)->void:
	var email = args[0]
	var password = args[1]
	
	if args.size() == 2:
		Network.auth(email, password)
		return


func command_client(args:PoolStringArray)->void:
	if args.size() == 0:
		Network.create_client()
		return
	
	if args.size() == 1:
		var ip = args[0]
		Network.create_client(ip)
		return
	
	if args.size() == 2:
		var ip = args[0]
		var port = args[1]
		Network.create_client(ip, port)
		return
	
	if args.size() == 3:
		var ip = args[0]
		var port = args[1]
		var key = args[2]
		Network.create_client(ip, port, key)
		return



func command_match(args:PoolStringArray):
	Network.create_match()
	pass

# Handles what happens when this user
# has received a message from the server
# ---------------------------------------
# Should ONLY add a message to the chat log
func _receive_message(text, sender)->void:
	if sender == username:
		return
	
	_add_message(text, sender)



# Local Chatting Private utils

# Function called on the client when
# the user has submited his message
# -----------------------------------
# IF the message is not a command
# The message is sent to the network
# and is added to the local log and
# the typing history regardless
func _write_message(text, sender)->void:
	# Only send to the network if its NOT a command.
	# If a command does networking stuff,
	# the COMMAND should handle that.
	if !text.begins_with("/") and Network._socket:
		Network.send_message(text)
	
	
	_add_message(text, sender)
	_add_history(text)


# Adds a label or tag before the message on the chat
func _add_label(name, color, last=false)->void:
	ChatLog.bbcode_text += "[color=" + color + "]"
	if last:
		ChatLog.bbcode_text += "["+ name +"]"
		ChatLog.bbcode_text += "[/color]: "
	else:
		ChatLog.bbcode_text += "["+ name +"] "
		ChatLog.bbcode_text += "[/color]"


func _add_text(text, color)->void:
	ChatLog.bbcode_text += "[color=" + color + "]"
	ChatLog.bbcode_text += text
	ChatLog.bbcode_text += "[/color]"


# Adds the sender(inside a label/tag) followed by the text
# NO NETWORKING INVOLVED
func _add_message(text, sender)->void:
	ChatLog.bbcode_text += "\n "
	
	_add_label(Types.chat.name, Types.chat.color)
	_add_label(sender, Types.chat.owner_color, true)
	
	_add_text(text, Types.chat.text_color)
	
	InputField.text = ""


# ONLY responsible for running a given command
func _run_command(text:String)->void:
	var params : PoolStringArray = text.split(" ")
	var command_name : String = params[0].trim_prefix("/")
	
	params.remove(0) # removes the first index (the command)
	
	if !Commands.has(command_name) and !self.has_method(command_name):
		log_error('"' + command_name + '"' + " command was not found!")
		return
	
	# Run the command
	Commands[command_name].command.call_func(params)
	InputField.text = ""

# Callbacks
func _on_text_entered(text:String)->void:
	if !InputField.text.empty():
		_write_message(text, username)
	
	if text.begins_with("/"):
		_run_command(text)

	

# ==============================================================================









