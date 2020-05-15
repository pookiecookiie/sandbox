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
const BLACK = "#000"
const DARK_GREY = "#555"

const DARK_RED = "#a00"
const RED = "#f00"
const LIGHT_RED = "#f55"

const DARK_GREEN = "#0a0"
const GREEN = "#0f0"
const LIGHT_GREEN = "#5f5"

const DARK_BLUE = "#00a"
const BLUE = "#00f"
const LIGHT_BLUE = "#0ff"

const DARK_YELLOW = "#aa0"
const YELLOW = "#ff0"
const LIGHT_YELLOW = "#ff5"

const PURPLE = "#a0f"
const PINK = "#f0f"

const GREY = "#aaa"
const WHITE = "#fff"


var Types = {
	"none": null,
	"chat": {
		"name": "chat",
		"color": GREEN,
		"owner_color": GREY, # Command or username label/TAG
		"text_color": WHITE,
		"text_bg_color": DARK_GREY,

	},
	"debug": {
		"name": "debug",
		"color": GREEN,
		"text_color": WHITE,
		"text_bg_color": DARK_GREY,
	},
	"server": {
		"name": "server",
		"color": GREEN,
		"text_color": WHITE,
		"text_bg_color": DARK_GREY,
	},
	"info": {
		"name": "info",
		"color": GREEN,
		"text_color": WHITE,
		"text_bg_color": DARK_GREY,
	},
	"help": {
		"name": "help",
		"color": GREEN,
		"text_color": WHITE,
		"text_bg_color": DARK_GREY,
	},
	"command": {
		"name": "chat",
		"color": GREEN,
		"text_color": WHITE,
		"text_bg_color": DARK_GREY,
	},
	"success": {
		"name": "success",
		"color": GREEN,
		"text_color": WHITE,
		"text_bg_color": DARK_GREY,
	},
	"warning": {
		"name": "warning",
		"color": GREEN,
		"text_color": WHITE,
		"text_bg_color": DARK_GREY,
	},
	"error": {
		"name": "error",
		"color": GREEN,
		"text_color": WHITE,
		"text_bg_color": DARK_GREY,
	},
	"say": {
		"name": "say",
		"color": GREEN,
		"text_color": WHITE,
		"text_bg_color": DARK_GREY,
	},
}


var Commands = {
	"none": null,
	"help": {
		"name": "help",
		"color": DARK_YELLOW,
		"command": funcref(self, "command_help")
	},
	
	"info": {
		"name": "help",
		"color": DARK_YELLOW,
		"command": funcref(self, "command_info")
	},
	
	"say": {
		"name": "help",
		"color": DARK_YELLOW,
		"command": funcref(self, "command_say")
	},
	
	"server":{
		"name": "help",
		"color": DARK_YELLOW,
		"command": funcref(self, "command_server")
	},
	
	"history": {
		"name": "help",
		"color": DARK_YELLOW,
		"command": funcref(self, "command_history")
	},
	
	"clear": {
		"name": "help",
		"color": DARK_YELLOW,
		"command": funcref(self, "command_clear")
	},
	
	"auth":{
		"name": "help",
		"color": DARK_YELLOW,
		"command": funcref(self, "command_auth")
	},
	
	"socket": {
		"name": "help",
		"color": DARK_YELLOW,
		"command": funcref(self, "command_socket")
	},
	
	"send": {
		"name": "help",
		"color": DARK_YELLOW,
		"command": funcref(self, "command_send")
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
	Network.connect("received_channel_message", self, "_receive_message")
	
	InputField.connect("text_entered", self, "_on_text_entered")
	
	InputLabel.text = "["+username+"]"
	
	ChatLog.scroll_following = true
	
	log_info("Type '/help' for help.")


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


func debug(text, type=Types.debug)->void:
	ChatLog.bbcode_text += "\n "
	
	_add_label(type.name, type.color)
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


func log_say(args)->void:
	debug(args, Types.say)



# Commands
func command_say(args:PoolStringArray)->void:
	log_say(args.join(" "))


func command_history(_args:PoolStringArray)->void:
	var history = typing_history.history
	log_info("Your typing history: " + str(history))


func command_clear(_args:PoolStringArray)->void:
	ChatLog.bbcode_text = ""
	log_info("Chat cleared!")


func command_help(_args:PoolStringArray)->void:
	log_info("""
	========
	>> HELP
	================================================================================
	
	@ COMMANDS
	
	> /help >> shows this help thing
	> /say (MESSAGE) >> logs a message (MESSAGE) to the chat.
	> /clear >> clears the chat.
	> /history >> shows your typing history. (up to 25 messages or commands)
	> /chat color (HEX_COLOR) >> changes the color of the CHAT.
	> /network id >> shows your Network's Unique Id.
	> /network peers >> shows a list of your peers. (if any)
	
	
	@ WIP
	
	> /lan create >> creates a LAN server on the default port. (42069)
	> /lan create (PORT) >> creates a LAN server on port (PORT).
	> /lan join (IP) (PORT) >> joins a LAN server on (IP):(PORT).
	> /lan leave >> leaves the currently connected server.
	
	> If you think a command is missing, please contact me at github >> https://github.com/pookiecookiie/sandbox/issues
	> - the dev
	================================================================================
	""")


func command_socket(args:PoolStringArray)->int:
	var prop = args[0]
	var prop_args = _get_prop_args(args)
	
	if args.size() == 0:
		Network.connect_socket()
		return OK
	
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
	


func command_send(args:PoolStringArray)->void:
	Network.send_message(args.join(" "))



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
	if !text.begins_with("/"):
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









