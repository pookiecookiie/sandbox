extends Control


onready var UsernameInput : LineEdit = $CenterContainer/Center/ContentMargin/SignUpFields/UsernameField/LineEdit
onready var EmailInput : LineEdit = $CenterContainer/Center/ContentMargin/SignUpFields/EmailField/LineEdit
onready var PasswordInput : LineEdit = $CenterContainer/Center/ContentMargin/SignUpFields/PasswordField/LineEdit
onready var SignUpButton : Button = $CenterContainer/Center/ContentMargin/SignUpFields/SignUp
onready var SignInButton : Button = $CenterContainer/Center/ContentMargin/SignUpFields/SignIn

var username : String = ""
var email : String = ""
var password : String = ""

func _ready():
	#UsernameInput.connect("text_entered", self, "_on_input_entered")
	#EmailInput.connect("text_entered", self, "_on_input_entered")
	PasswordInput.connect("text_entered", self, "_on_input_entered")
	
	SignUpButton.connect("pressed", self, "_handle_sign_up")
	SignInButton.connect("pressed", self, "_switch_to_sign_in")


func _on_input_entered():
	username = UsernameInput.text
	email = EmailInput.text
	password = PasswordInput.text

func _handle_sign_up():
	username = UsernameInput.text
	email = EmailInput.text
	password = PasswordInput.text
	
	Network.sign_up(email, password, username)
	

func _switch_to_sign_in():
	hide()
	get_parent().get_node("SignIn").visible = true



