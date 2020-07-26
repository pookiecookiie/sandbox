extends VBoxContainer


onready var Messages = $Messages
onready var ChatBox = $ChatBox

func _ready():
	# Maybe persist direct messages
	pass


func _input(event):
	if event.is_action_pressed("ui_accept"):
		ChatBox.grab_focus()
	
	if event.is_action_pressed("ui_cancel"):
		ChatBox.release_focus()

