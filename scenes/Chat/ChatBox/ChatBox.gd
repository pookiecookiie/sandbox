extends LineEdit


onready var Chat = get_parent()
onready var Commands : Node = Chat.get_node("Commands")

var username = "Guest_" + str(randi()) # Grab from the current session later
var chatname = "LOCAL" # Grab this from the CHAT settings

func _ready():
	connect("text_entered", self, "text_entered")


func text_entered(text:String):
	if text.begins_with("/"):
		var splitted : PoolStringArray = text.split(" ")
		
		var command = splitted[0].substr(1)
		splitted.remove(0) # remove the command
		var args = Array(splitted)
		
		run_command(command, args)
	else:
		send_message(text)


func send_message(text:String):
	Chat.Messages.say(text, username, chatname)
	self.text = ""


func run_command(command:String, args:Array):
	if Commands.has_method(command):
		Commands.call(command, args)
	else:
		print("doesnt")
		Chat.debug("Command not found!")
	self.text = ""
	

