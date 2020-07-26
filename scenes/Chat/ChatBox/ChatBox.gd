extends LineEdit


onready var Chat = get_parent()
onready var Commands : Node = Chat.get_node("Commands")

var username = "Guest_" + str(randi()) # Grab from the current session later
var chatname = "LOCAL" # Grab this from the CHAT settings

var latest_message = 0
var latest_messages = []


func _ready():
	connect("text_entered", self, "text_entered")
	Network.connect("authenticated", self, "_handle_authentication")


func _handle_authentication(session):
	username = session.username


func _input(event):
	var history_input = false
	
	if event.is_action_pressed("ui_up"):
		go_back_history()
		history_input = true
	if event.is_action_pressed("ui_down"):
		go_forward_history()
		history_input = true
	
	if history_input:
		self.caret_position = self.text.length()
		grab_focus()


func go_back_history():
	if latest_message-1 >= 0:
		latest_message -= 1
		self.text = latest_messages[latest_message]


func go_forward_history():
	if latest_message+1 < latest_messages.size():
		latest_message += 1
		self.text = latest_messages[latest_message]


func text_entered(text:String):
	if text.empty():
		return # Please
	
	send_message(text)
	
	if text.begins_with("/"):
		var splitted : PoolStringArray = text.split(" ")
		
		var command = splitted[0].substr(1)
		splitted.remove(0) # remove the command
		var args = Array(splitted)
		
		run_command(command, args)
	elif Network.channel and Network.socket_connected:
		send_network_message(text)
		
	
	
	# Used to cycle through the latest messages sent
	latest_messages.append(text)
	latest_message = latest_messages.size()

func send_network_message(text:String):
	if Network.channel and Network.socket_connected:
		Network.send_message(text, username, chatname)


func send_message(text:String):
	Chat.Messages.say(text, username, chatname)
	self.text = ""


func run_command(command:String, args:Array):
	if Commands.has_method(command):
		Commands.call(command, args)
	else:
		UI.error("Command not found!", self.name)
	
	self.text = ""
	

