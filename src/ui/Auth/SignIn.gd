extends Control


onready var EmailLineEdit : LineEdit= $CenterContainer/Center/ContentMargin/SignInFields/EmailField/LineEdit
onready var PasswordLineEdit : LineEdit = $CenterContainer/Center/ContentMargin/SignInFields/PasswordField/LineEdit

onready var SignInButton = $CenterContainer/Center/ContentMargin/SignInFields/SignInButton
onready var SignUpButton = $CenterContainer/Center/ContentMargin/SignInFields/SignUpButton


var email : String = ""
var password : String = ""


func _ready():
	SignInButton.connect("pressed", self, "_handle_sign_in")
	SignUpButton.connect("pressed", self, "_handle_sign_up")


func _handle_sign_in():
	email = EmailLineEdit.text
	password = PasswordLineEdit.text
	
	Network.sign_in(email, password)
	hide()


func _handle_sign_up():
	hide()
	get_parent().get_node("SignUp").visible = true



