extends VBoxContainer


onready var Messages = $Messages
onready var ChatBox = $ChatBox

func _ready():
	# Maybe persist direct messages
	pass


func _input(_event):
	if Input.is_action_just_pressed("ui_accept"):
		ChatBox.grab_focus()

