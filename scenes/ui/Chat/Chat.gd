extends Control


# ==============================================================================
#
# Chat

#	This is a template for organizing parts of files.
#	Make sure to try to keep it consistent and organized so you don't fuck your-
#self up anymore with organization and clutter on files.

# ==============================================================================


# ==============================================================================
#
# Nodes

onready var ChatLog = $VBox/Panel/TextBox
onready var InputLabel = $VBox/Panel/HBox/Player
onready var InputField = $VBox/Panel/HBox/Input

# ==============================================================================


# ==============================================================================
#
# Error, Warning and Log message templates

const Error = {
	"COMMAND_NOT_FOUND": "Command not found.",
	"COMMAND_INVALID_ARGS": "Invalid Command Arguments.",
	"COMMAND_INVALID_PERMISSION": "You don't have permission to execute this command.",
	"INVALID_HEX": "Not a valid HEXADECIMAL number.",
	"INVALID_IP": "Not a valid IP ADDRESS.",
}

const Warning = {
	"NOT_CONNECTED": "You are not connected to a network, try creating or hosting a game.",
	"NO_CONNECTED_PEERS": "There are no peers connected on your network.",
	"PEER_LAG": "Your peer's internet connection is LAGGIN quite a bit.",
	"LAG": "Your internet connection is LAGGING quite a bit.",
	"WTF": "uhhhh.... ok?"
}

const Log = {
	"NETWORK_ID": "Connected! Your network id is: ",
	"NETWORK_PEERS": "Connected! Your network peers are: ",
	"PING": "PING: ",
	"TYPING_HISTORY": "Your Typing history is: ",
	"CHAT_COLOR_CHANGED": "Chat color was changed!"
}


# ==============================================================================


# ==============================================================================
#
# Chat types

#	Takes care of styling and separating the chat visually for the user(me) ease

const ChatTypes = {
	"chat": {
		"name": "chat",
		"label_color":"#AF0",
		"username_color": "#AAA",
		"text_color": "#FFF"
	},
	"command": {
		"name": "cmd",
		"label_color":"#FA0",
		
		# Commands
		"warning": {
			"name": "warning",
			"label_color":"#FF0",
			"text_color": "#FF5"
		},
		"error": {
			"name": "error",
			"label_color":"#F00",
			"text_color": "#F55"
		},
		"server": {
			"name": "server",
			"label_color":"#F0A",
			"text_color": "#F5A"
		},
		"say": {
			"name": "say",
			"label_color": "#FA0",
			"text_color": "#FA5"
		},
		"set": {
			"name": "set",
			"label_color": "#0FA",
			"text_color": "#5FA"
		},
		"clear": {
			"name": "clear",
			"label_color": "#FA0",
			"text_color": "#FA5"
		}
	},
}

# ==============================================================================


# ==============================================================================
#
# Chat Function things

const ChatFunctions = {
	"server": "server",
	"error": "error",
	"warning": "warning",
	"say": "say",
	"set": "set",
	"clear": "clear"

}

# ==============================================================================


# ==============================================================================
#
# Member Variables

var username : String = "Guest"

# Typing history actually
var chat_log = {
	"now": 1,
	"type_history": [],
	"max_type_history": 25,
}



# ==============================================================================


# ==============================================================================
#
# Godot functions

func _ready():
	InputField.connect("text_entered", self, "_on_text_entered")
	InputLabel.text = "["+username+"]"
	
	ChatLog.scroll_following = true


func _input(event:InputEvent):
	if event.is_action_pressed("ui_accept"):
		InputField.grab_focus()
	
	
	if event.is_action_pressed("ui_cancel"):
		InputField.release_focus()
	
	
	if event.is_action_pressed("ui_up"):
		print("") # for some reason without print here it doesnt work??
		var previous = chat_log.now - 1
		if !previous < 0 and !chat_log.type_history.empty():
			InputField.text = chat_log.type_history[previous]
			chat_log.now = previous
	
	
	if event.is_action_pressed("ui_down"):
		print("")
		var next = chat_log.now + 1
		if !next > chat_log.type_history.size()-1:
			InputField.text = chat_log.type_history[next]
			chat_log.now = next


# ==============================================================================


# ==============================================================================
#
# Utilities


func add_history(text):
	chat_log.type_history.append(text)
	chat_log.now = chat_log.type_history.size()
	
	if chat_log.type_history.size() > chat_log.max_type_history:
			chat_log.type_history.pop_front()


func add_label(name, color, last=false):
	ChatLog.bbcode_text += "[color=" + color + "]"
	if last:
		ChatLog.bbcode_text += "["+ name +"]"
		ChatLog.bbcode_text += "[/color]: "
	else:
		ChatLog.bbcode_text += "["+ name +"] "
		ChatLog.bbcode_text += "[/color]"


func add_text(text, color):
	ChatLog.bbcode_text += "[color=" + color + "]"
	ChatLog.bbcode_text += text
	ChatLog.bbcode_text += "[/color]"


func add_log(text, username=null):
	ChatLog.bbcode_text += "\n "
	
	add_label(ChatTypes.chat.name.to_upper(), ChatTypes.chat.label_color)
	
	if username:
		add_label(username, ChatTypes.chat.username_color, true)
	add_text(text, ChatTypes.chat.text_color)
	
	if username:
		add_history(text)


func add_command(text, chat_command):
	if chat_command == ChatTypes.command.error:
		self.visible = true
	
	var command = ChatTypes.command[chat_command.name]
	
	ChatLog.bbcode_text += "\n "
	add_label(ChatTypes.command.name.to_upper(), ChatTypes.command.label_color)
	add_label(command.name.to_upper(), command.label_color, true)
	add_text(text, command.text_color)


func run_chat_function(raw:PoolStringArray):
	var function = raw[0]
	
	raw.remove(0)
	var params = raw
	
	if function == ChatFunctions.server:
		#TODO:
		#
		#Only callable if this is the server
		
		log_server(params.join(" "))
		return
	
	
	if function == ChatFunctions.say:
		__say(params.join(" "))
		return
	
	if function == ChatFunctions.set:
		__set(params)
		return
	
	if function == ChatFunctions.clear:
		clear_log()
		return
	
	log_error(Error.COMMAND_NOT_FOUND)
	

# ==============================================================================


# ==============================================================================
#
# Chat Functions

# UTILITY
func log_server(msg):
	add_command(msg, ChatTypes.command.server)

func log_error(msg):
	add_command(msg, ChatTypes.command.error)

func log_warning(msg):
	add_command(msg, ChatTypes.command.warning)


func concatenate_strings(strings, separator=" =>", wrapper=["[ ", " ]"]):
	# Refactor later on, but works fine now
	var string : String = ""
	
	for i in range(strings.size()):
		if i < strings.size()-1:
			string += strings[i]
			string += separator
		else:
			string += wrapper[0]
			string += strings[i]
			string += wrapper[1]
	
	return string


func toggle():
	self.visible = !self.visible

# COMMANDS
func __say(msg):
	if msg == "history":
		var history = chat_log.type_history
		__say(Log.TYPING_HISTORY + str(history))
		return
	
	if msg == "networkID":
		var id = get_tree().get_network_unique_id()
		if id == 0:
			log_warning(Warning.NOT_CONNECTED)
			return
		__say(Log.NETWORK_ID + '"'+str(id)+'"')
		return
	
	if msg == "networkPeers":
		var peers = get_tree().get_network_connected_peers()
		if peers.empty():
			log_warning("There are no peers connected to your network!")
			return
		__say(Log.NETWORK_PEERS + " " + str(peers))
		return
	
	
	add_command(msg, ChatTypes.command.say)


func __set(args):
	var prop : String = args[0]
	var prop_args : Array = []
	
	# Separate prop from other args
	# Kind of argument nesting weird thing going on
	for arg in args:
		if arg != prop:
			prop_args.append(arg)
	
	
	if prop == "color":
		if prop_args[0].is_valid_hex_number():
			ChatTypes.chat.text_color = "#"+prop_args[0]
			
			__say(Log.CHAT_COLOR_CHANGED)
			return
		else:
			var err = concatenate_strings([
				Error.COMMAND_INVALID_ARGS,
				Error.INVALID_HEX,
				prop_args[0]
			])
			
			log_error(err)
			return
	
	log_error(Error.COMMAND_NOT_FOUND)


func clear_log():
	ChatLog.bbcode_text = ""
	add_log("Chat cleared!", null)


# ==============================================================================


# ==============================================================================
#
# Callbacks

func _on_text_entered(text:String):
	if !InputField.text.empty():
		add_log(text, username)
	InputField.text = ""
	

	if text.begins_with("/"):
		# Get rid of the slash
		text.erase(0, 1)
		
		var splitted : PoolStringArray = text.split(" ")
		run_chat_function(splitted)
		InputField.text = ""
		return

# ==============================================================================









