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


# ==============================================================================
#
# Chat configuration

const chat_config = {
	"name": "chat",
	"label_color":"#AF0",
	"username_color": "#AAA",
	"text_color": "#FFF"

}

const command_config = {
	"name": "cmd",
	"label_color": "#FA0",
	"text_color": "#FA5"
}

var commands = {
	"warning": {
		"name": "warning",
		"label_color":"#FF0",
		"text_color": "#FF5",
		"command": funcref(self, "warning")
	},
	"error": {
		"name": "error",
		"label_color":"#F00",
		"text_color": "#F55",
		"command": funcref(self, "error")
	},
	"success": {
		"name": "success",
		"label_color": "#0F0",
		"text_color": "#5F0",
		"command": funcref(self, "success")
	},
	"command": {
		"name": "command",
		"label_color": "#FA0",
		"text_color": "#FA5",
		"command": funcref(self, "command")
	},
	"server": {
		"name": "server",
		"label_color":"#F0A",
		"text_color": "#F5A",
		"command": funcref(self, "server")
	},
	"say": {
		"name": "say",
		"label_color": "#FA0",
		"text_color": "#FA5",
		"command": funcref(self, "say")
	},
	"history": {
		"name": "history",
		"label_color": "#FA0",
		"text_color": "#FA5",
		"command": funcref(self, "history")
	},
	"chat": {
		"name": "chat",
		"label_color": "#0FA",
		"text_color": "#5FA",
		"command": funcref(self, "chat")
	},
	"network": {
		"name": "network",
		"label_color": "#0FA",
		"text_color": "#5FA",
		"command": funcref(self, "network") 
	},
	"clear": {
		"name": "clear",
		"label_color": "#FA0",
		"text_color": "#FA5",
		"command": funcref(self, "clear")
	},
	"lan": {
		"name": "lan",
		"label_color": "#0FA",
		"text_color": "#5FA",
		"command": funcref(self, "lan") 
	},
	"help": {
		"name": "help",
		"label_color": "#FFF",
		"text_color": "#0F0",
		"command": funcref(self, "help") 
	},
	"create": {
		"name": "create",
		"label_color": "#555",
		"text_color": "#FFF",
		"command": funcref(self, "create") 
	},
	"tp": {
		"name": "tp",
		"label_color": "#555",
		"text_color": "#FFF",
		"command": funcref(self, "tp") 
	},
	"auth": {
		"name": "auth",
		"label_color": "#555",
		"text_color": "#FFF",
		"command": funcref(self, "auth") 
	},
	"socket": {
		"name": "socket",
		"label_color": "#555",
		"text_color": "#FFF",
		"command": funcref(self, "socket") 
	},
	"send": {
		"name": "send",
		"label_color": "#555",
		"text_color": "#FFF",
		"command": funcref(self, "send") 
	}
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
	log_command("Type '/help' for help.", commands.help)


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


# ==============================================================================


# ==============================================================================
#
# Utilities

func log_command(args, command_name=commands.command):
	send_command(args, command_name)

func log_error(args):
	send_command(args, commands.error)

func log_warning(args):
	send_command(args, commands.warning)

func log_success(args):
	send_command(args, commands.success)

func log_server(args):
	send_command(args, commands.server)

func log_help(args):
	send_command(args, commands.help)

func log_say(args):
	send_command(args, commands.say)


func toggle():
	self.visible = !self.visible

func open():
	self.visible = true

func close():
	self.visible = false

func get_prop_args(args):
	var prop_args = []
	
	for arg in args:
		if arg != args[0]:
			prop_args.append(arg)
	return prop_args


func send_message(text, _username=null):
	ChatLog.bbcode_text += "\n "
	
	add_label(chat_config.name.to_upper(), chat_config.label_color)
	
	if _username:
		add_label(username, chat_config.username_color, true)
	add_text(text, chat_config.text_color)
	
	if _username:
		add_history(text)



# Log the command output to the 
func send_command(text, chat_command):
	if chat_command == commands.error:
		self.open()
	
	var command_type = commands[chat_command.name]
	
	ChatLog.bbcode_text += "\n "
	add_label(command_config.name.to_upper(), command_config.label_color)
	add_label(command_type.name.to_upper(), command_type.label_color, true)
	add_text(text, command_type.text_color)


func command(args:PoolStringArray):
	send_command(args.join(" "), commands.command_log)

func error(args:PoolStringArray):
	send_command(args.join(" "), commands.error)

func warning(args:PoolStringArray):
	send_command(args.join(" "), commands.warning)

func success(args:PoolStringArray):
	send_command(args.join(" "), commands.success)

func server(args:PoolStringArray):
	send_command(args.join(" "), commands.server)

func say(args:PoolStringArray):
	send_command(args.join(" "), commands.say)


func history(_args:PoolStringArray):
	var history = chat_log.type_history
	log_command("Your typing history: " + str(history), commands.history)


func chat(args:PoolStringArray):
	var prop = args[0]
	var prop_args = get_prop_args(args)
	
	if prop.to_upper() == "COLOR":
		if prop_args[0].is_valid_hex_number():
			chat_config.text_color = "#"+prop_args[0]

			log_command("Chat Color has changed!", commands.chat)
			return
		else:
			log_error("Invalid arguments")
			return
	
	log_error("Command not found.")


func network(args:PoolStringArray):
	var prop = args[0]
	
	if prop.to_upper() == "ID":
		var id = get_tree().get_network_unique_id()
		
		if id == 0:
			log_warning("You are not connected to a network!")
			return
		log_command("Your network id is: " + '"'+str(id)+'"', commands.network)
		return
	
	if prop.to_upper() == "PEERS":
		var peers = get_tree().get_network_connected_peers()
		if peers.empty():
			log_warning("There are no peers!")
			return
		log_command("Connected peers: " + str(peers), commands.network)
		return
		


func lan(args:PoolStringArray):
	var prop = args[0]
	var prop_args = get_prop_args(args)
	
	if  prop.to_upper() == "CREATE":
		if prop_args.size() == 2:
			var port = prop_args[0]
			var max_clients = prop_args[1]
			Network.create_server(port, max_clients)
			return
			
		# Create default server otherwise
		Network.create_server()
	
	if prop.to_upper() == "JOIN":
		if prop_args.size() == 2:
			var ip = prop_args[0]
			var port = prop_args[1]
			Network.join_server(ip, port)
			return
		
		# Join default server
		Network.join_server()

	if prop.to_upper() == "LEAVE":
		Network.leave_server()
	


func clear(_args:PoolStringArray):
	ChatLog.bbcode_text = ""
	log_command("Chat cleared!", commands.clear)


func help(_args:PoolStringArray):
	log_command("""
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
""", commands.help)


func create(_args:PoolStringArray):
	var world = load("res://scenes/world/World.tscn").instance()
	get_node("/root").add_child(world)

	# Load my player
	var my_player = preload("res://scenes/world/Player/Player.tscn").instance()
	get_node("/root/world/players").add_child(my_player)
	
	self.visible = false


func tp(args:PoolStringArray):
	var prop :String = args[0]
	var prop_args = get_prop_args(args)
	
	if prop_args.size() == 3:
		var x = prop_args[0]
		var y = prop_args[1]
		var z = prop_args[2]
		
		for player in get_node("/root/world/players").get_children():
			if player.name == prop:
				player.translation = Vector3(x, y, z)


func socket(args:PoolStringArray):
	if args.size() == 0:
		Network.connect_socket()
		return
	
	var prop = args[0]
	
	if prop.to_upper() == "INFO":
		if !Network.current_channel:
			UI.Chat.log_error("Not connected to a channel")
			return
		
		UI.Chat.log_help("Channel info:")
		UI.Chat.log_help(str(Network.current_channel.room_name))
		UI.Chat.log_help(str(Network.current_channel.presences))

func auth(args:PoolStringArray):
	var prop = args[0]
	
	if prop.to_upper() == "SIGN":
		if args.size() == 2:
			UI.Chat.log_success("work")
			Network.sign_in()
			return

		if args.size() < 4:
			log_error("Please use: /auth sign in/up email password [username]")
			return
		
		var email = args[2]
		var password = args[3]
		var username
		if args.size() == 5:
			username = args[4]
		
		if args[1].to_upper() == "IN":
			Network.sign_in(email, password)
			
		if args[1].to_upper() == "UP":
			if username:
				Network.sign_up(email, password, username)
			else:
				log_error("uh... username pls")


func send(args:PoolStringArray):
	Network.send_message(args.join(" "))


func run_command(raw:PoolStringArray):
	var command_name = raw[0]
	
	raw.remove(0)
	var params = raw
	
	if !commands.has(command_name):
		log_error(str(command_name) + " command not found!")
		return
	
	commands[command_name].command.call_func(params)
	

# ==============================================================================


# ==============================================================================
#
# Callbacks

func _on_text_entered(text:String):
	if !InputField.text.empty():
		send_message(text, username)
	InputField.text = ""
	

	if text.begins_with("/"):
		# Get rid of the slash and try to run a chat function
		text.erase(0, 1)
		
		var splitted : PoolStringArray = text.split(" ")
		run_command(splitted)
		InputField.text = ""

# ==============================================================================









