extends VBoxContainer


onready var Messages = $Messages
onready var ChatBox = $ChatBox

func _ready():
	# Maybe persist direct messages
	pass


# Will log a message as DEBUG so will only be visible if UI>SETTINGS>DEBUG is true
func debug(message:String, from:String=""):
	# Definitely want to save this to a file at some point
	if from.empty():
		Messages.debug(message, from)
	else:
		Messages.debug(message)


func info(message:String, from:String=""):
	if from.empty():
		Messages.info(message, from)
	else:
		Messages.info(message)


func success(message:String, from:String=""):
	if from.empty():
		Messages.success(message, from)
	else:
		Messages.success(message)


func error(message:String, from:String=""):
	if from.empty():
		Messages.error(message, from)
	else:
		Messages.error(message)


