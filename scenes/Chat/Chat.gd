extends VBoxContainer


onready var Messages = $Messages
onready var ChatBox = $ChatBox
onready var Cache = $Cache

func _ready():
	# Maybe persist direct messages
	pass


# Will log a message as DEBUG so will only be visible if UI>SETTINGS>DEBUG is true
func debug(message:String, from:String=""):
	# Definitely want to save this to a file at some point
	ChatBox.debug_message(message, from)


func info(message:String, from:String=""):
	pass


func success(message:String, from:String=""):
	pass


func error(message:String, from:String=""):
	pass


