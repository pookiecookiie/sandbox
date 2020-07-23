extends Node

var credentials : Dictionary = {}


func save_credentials():
	if Network._session:
		return {
			"email": Network.session_email,
			"password": Network.session_password,
			"username": Network.session_username
		}





