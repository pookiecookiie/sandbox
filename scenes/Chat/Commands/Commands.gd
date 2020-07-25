extends Node

onready var Chat = get_parent()


func _ready():
	Network.connect("socket_connected", self, "socket_connected")


func socket_connected(socket):
	print("Connected to socket!")
	Network.create_channel()


func time(_args:Array):
	var time = OS.get_time()
	Chat.Messages.debug(str(time.hour) +":"+ str(time.minute) +":"+ str(time.second), self.name)


func logs(args:Array):
	if args.empty():
		return
	
	if args[0].to_upper() == "MESSAGE":
		Chat.Messages.debug("Message logs: " + str(Chat.Messages.logs.messages.size()), self.name)
	elif args[0].to_upper() == "DEBUG":
		Chat.Messages.debug("Debug logs: " + str(Chat.Messages.logs.debug.size()), self.name)


func account(args:Array):
	var credentials = Cache.data.session
	
	if credentials.has("email") and credentials.has("password"):
		Chat.Messages.debug("Logged in as: " + str(credentials), self.name)
	else:
		Chat.Messages.debug("Not logged in.", self.name)


func register(args:Array):
	var email = args[0]
	var password = args[1]
	var username = args[2]
	
	if not email.empty() and not password.empty() and not username.empty():
		Network.create_client()
		Network.auth(email, password, username)
	else:
		Chat.Messages.debug("Could not register, please try again.", self.name)


func login(args:Array):
	var email : String
	var password : String
	
	if args.empty():
		var accounts = Cache.accounts
		
		#HARDCODED
		if accounts.bobo.email.empty() || accounts.bobo.password.empty():
			print("Cached credentials are empty")
			return
		
		email = accounts.bobo.email
		password = accounts.bobo.password
	else:
		email = args[0]
		password = args[1]
	
	if not email.empty() and not password.empty():
		Network.create_client()
		Network.auth(email, password)
	else:
		Chat.Messages.debug("Could not login, please try again.", self.name)


func cache(args:Array):
	if args[0].to_upper() == "CREDENTIALS":
		if not Network.session:
			print("Nothing to cache")
			return
		
		var network_data = {
			"email": Network.session_email,
			"password": Network.session_password,
			"username": Network.session.username
		}
	
		Chat.Messages.debug("Caching credentials...")
		Cache.Messages.save_account(network_data.username, network_data)
	
	elif args[0].to_upper() == "VIEW":
		Chat.Messages.debug("Cache data: ")
		Chat.Messages.debug(str(Cache.data))
		Chat.Messages.debug(str(Cache.accounts))
		
		Chat.Messages.debug("Cache file data:")
		var cache = Cache.load_cache()
		if cache.has("data") and cache.has("accounts"):
			Chat.Messages.debug(str(cache.data))
			Chat.Messages.debug(str(cache.accounts))
		


# Host a server thing
func host(args:Array):
	Network.create_socket()


# Connect to a server thing
func join():
	pass



# Using rpc...maybe ( if i cant figure out how to get Nakama to work )
func create_server():
	pass

# Using rpc...maybe ( if i cant figure out how to get Nakama to work )
func enter_server():
	pass


func test(args:Array):
	if args[0].to_upper() == "ONE":
		Chat.debug("Saving some data: {hello: 'hi'")
		Cache.save_data("hello", "hi")
	if args[0].to_upper() == "TWO":
		Chat.debug("Saving some data: {hello: 'changed'")
		Cache.save_data("hello", "changed")
	if args[0].to_upper() == "THREE":
		Chat.debug("Saving some data: {bye: 'goodbye'")
		Cache.save_data("bye", "goodbye")
	if args[0].to_upper() == "FOUR":
		Chat.debug("Erasing 'hello'")
		Cache.erase_data("hello")



