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

onready var ChatLog = $VBox/TextBox
onready var InputLabel = $VBox/HBox/Player
onready var InputField = $VBox/HBox/Input

# ==============================================================================
#
# Chat configuration

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
		"user_color": GREY,
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

# Typing history actually
var chat_log = {
	"now": 1,
	"type_history": [],
	"max_type_history": 25,
}

var username : String = "guest"


# ==============================================================================


# ==============================================================================
#
# Godot functions

func _ready():
	InputField.connect("text_entered", self, "_on_text_entered")
	InputLabel.text = "["+username+"]"
	
	Types.chat.command = username
	
	ChatLog.scroll_following = true
	
	log_info("Type '/help' for help.")


func _input(event:InputEvent):
	if event.is_action_pressed("open_chat"):
		InputField.grab_focus()
	
	
	if event.is_action_pressed("close_chat"):
		InputField.release_focus()
	
	# Go back on typing history 
	if event.is_action_pressed("ui_up"):
		print("") # for some reason without print here it doesnt work??
		var previous = chat_log.now - 1
		if !previous < 0 and !chat_log.type_history.empty():
			InputField.text = chat_log.type_history[previous]
			chat_log.now = previous
	
	# Go forward on typing history
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

# PRIVATE FUNCTIONS

func _add_history(text):
	chat_log.type_history.append(text)
	chat_log.now = chat_log.type_history.size()
	
	if chat_log.type_history.size() > chat_log.max_type_history:
			chat_log.type_history.pop_front()


func _add_label(name, color, last=false):
	ChatLog.bbcode_text += "[color=" + color + "]"
	if last:
		ChatLog.bbcode_text += "["+ name +"]"
		ChatLog.bbcode_text += "[/color]: "
	else:
		ChatLog.bbcode_text += "["+ name +"] "
		ChatLog.bbcode_text += "[/color]"

func _add_text(text, color):
	ChatLog.bbcode_text += "[color=" + color + "]"
	ChatLog.bbcode_text += text
	ChatLog.bbcode_text += "[/color]"


func _get_prop_args(args):
	var prop_args = []
	
	for arg in args:
		if arg != args[0]:
			prop_args.append(arg)
	return prop_args

# PUBLIC FUNCTIONS

func toggle():
	self.visible = !self.visible

func open():
	self.visible = true

func close():
	self.visible = false

func clear():
	self.ChatLog.bbcode_text = ""

func set_username(new):
	username = new
	Types.chat.command = username
	InputLabel.text = "["+username+"]"
	

# ==============================================================================


# ==============================================================================
#
# Commands

func debug(args):
	write_info(args, Types.debug)

func log_help(args):
	write_info(args, Types.help)

func log_info(args):
	write_info(args, Types.info)

func log_server(args):
	write_info(args, Types.server)

func log_success(args):
	write_info(args, Types.success)

func log_warning(args):
	write_info(args, Types.warning)

func log_error(args):
	write_info(args, Types.error)

func log_say(args):
	write_info(args, Types.say)


func command_say(args:PoolStringArray):
	log_say(args.join(" "))

func command_history(_args:PoolStringArray):
	var history = chat_log.type_history
	log_info("Your typing history: " + str(history))


func command_clear(_args:PoolStringArray):
	ChatLog.bbcode_text = ""
	log_info("Chat cleared!")


func command_help(_args:PoolStringArray):
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


func command_auth(args:PoolStringArray):
	var email = args[0]
	var password = args[1]
	
	if args.size() == 2:
		Network.auth(email, password)
		return
	


func command_send(args:PoolStringArray):
	Network.send_message(args.join(" "))


func receive_message(text, sender):
	if sender == username:
		return
	
	add_message(text, sender)


func write_message(text, sender):
	if !text.begins_with("/"):
		Network.send_message(text)
	
	add_message(text, sender)


func add_message(text, sender):
	ChatLog.bbcode_text += "\n "
	
	_add_label(Types.chat.name, Types.chat.color)
	_add_label(sender, Types.chat.user_color, true)
	
	_add_text(text, Types.chat.text_color)
	_add_history(text)
	
	InputField.text = ""


func write_info(text, type=Types.info):
	ChatLog.bbcode_text += "\n "
	
	_add_label(type.name, type.color)
	_add_text(text, type.text_color)


func _run_command(text:String):
	var params : PoolStringArray = text.split(" ")
	var command_name : String = params[0].trim_prefix("/")
	
	params.remove(0) # removes the first index (the command)
	
	if !Commands.has(command_name) and !self.has_method(command_name):
		log_error('"' + command_name + '"' + " command not found!")
		return
	
	# Run the command
	Commands[command_name].command.call_func(params)
	InputField.text = ""
	

# ==============================================================================


# ==============================================================================
#
# Callbacks

func _on_text_entered(text:String):
	if !InputField.text.empty():
		write_message(text, username)
	
	if text.begins_with("/"):
		_run_command(text)

	

# ==============================================================================









