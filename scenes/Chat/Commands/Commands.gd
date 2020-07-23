extends Node

onready var Chat = get_parent()


func time(_args:Array):
	var time = OS.get_time()
	Chat.debug(str(time.hour) +":"+ str(time.minute) +":"+ str(time.second))


func logs(args:Array):
	if args[0].to_upper() == "MESSAGE":
		Chat.debug("Message logs: " + str(Chat.Messages.logs.messages.size()))
	elif args[0].to_upper() == "DEBUG":
		Chat.debug("Debug logs: " + str(Chat.Messages.logs.debug.size()))


func account(args:Array):
	var credentials = {
		"email": Network.session_email,
		"password": Network.session_password,
	}
	
	if credentials.email and credentials.password:
		Chat.debug("Logged in as: " + str(credentials))
	else:
		Chat.debug("Not logged in.")


func register(args:Array):
	var email = args[0]
	var password = args[1]
	var username = args[2]
	
	if not email.empty() and not password.empty() and not username.empty():
		Network.create_client("643b4b4e2253.ngrok.io", 0)
		Network.auth(email, password, username)
	else:
		Chat.debug("Could not register, please try again.")


func login(args:Array):
	var email : String
	var password : String
	
	if args.empty():
		var credentials = Chat.Cache.load_cache_credentials()
		email = credentials.email
		password = credentials.password
	else:
		email = args[0]
		password = args[1]
	
	if not email.empty() and not password.empty():
		Network.create_client("643b4b4e2253.ngrok.io", 0)
		Network.auth(email, password)
	else:
		Chat.debug("Could not login, please try again.")


func cache(args:Array):
	if args[0].to_upper() == "CREDENTIALS":
		Chat.debug("Caching...")
		Chat.Cache.cache_credentials()
	elif args[0].to_upper() == "DISPLAY":
		if args[1].to_upper() == "CREDENTIALS":
			Chat.debug(str(Chat.Cache.load_cache_credentials()))


# Host a server thing
func host():
	Network.create_socket()
	Network.create_channel()


# Connect to a server thing
func join():
	pass



# Using rpc...maybe ( if i cant figure out how to get Nakama to work )
func create_server():
	pass

# Using rpc...maybe ( if i cant figure out how to get Nakama to work )
func enter_server():
	pass


