extends Node

onready var Chat = get_parent()

var help_pages = {
	"1": """
# HELP 1 #

* /help [page] -> to see the help page[page]
* /time -> to see the current time
* /logs -> to see the message logs
* /clear -> to clear all messages in the chat
* /account -> to see the current logged in account
* /register [email] [password] [username] -> Registers an account with credentials
* /login [email] [password -> Logs in to the account with credentials], if no
credentials are specified, it will try to login from the cached credentials
* /cache credentials -> attempts to cache the current logged in account
* /cache view -> logs the current cache information to the chat
* /host [ip], [port] -> hosts a room ("default")
""",
	"2": """
# HELP 2 #

W I P
"""
}


func help(args:Array):
	if args.empty():
		Chat.Messages.info(help_pages["1"], self.name)
		return
	
	var page = int(args[0])
	
	if page > 0 and page < help_pages.size():
		Chat.Messages.info(help_pages[page], self.name)


func clear(_args:Array):
	Chat.Messages.bbcode_text = ""
	Chat.Messages.success("Chat Cleared!", self.name)


func time(_args:Array):
	var time = OS.get_time()
	Chat.Messages.info("Time now: " + str(time.hour) +":"+ str(time.minute) +":"+ str(time.second), self.name)


func logs(args:Array):
	Chat.Messages.info("Message logs: " + str(Cache.messages.size()), self.name)


func account(args:Array):
	var credentials = Cache.session
	
	if credentials.has("email") and credentials.has("password"):
		Chat.Messages.debug("Logged in as: " + str(credentials), self.name)
	else:
		Chat.Messages.debug("Not logged in.", self.name)


func register(args:Array):
	var email = args[0]
	var password = args[1]
	var username = args[2]
	
	if not email.empty() and not password.empty() and not username.empty():
		Network.auth(email, password, username)
	else:
		Chat.Messages.debug("Could not register, please try again.", self.name)


func login(args:Array):
	var email : String
	var password : String
	var cached = false
	
	if args.empty():
		UI.error("* /login expects at least 1 argument.", self.name)
		return
	
	if args.size() == 1:
		cached = true
		
		if !Cache.cache.has("accounts"):
			UI.error("No accounts cached to login.", self.name)
			return
		
		var username = args[0]
		if !Cache.accounts.has(username):
			UI.error("Username not found in cache.", self.name)
			return
		
		if !Cache.accounts[username].has("email") or !Cache.accounts[username].has("password"):
			UI.error("Credentials are empty.", self.name)
			return
		
		UI.info("Logging in...", self.name)
		email = Cache.accounts[username].email
		password = Cache.accounts[username].password
	else:
		email = args[0]
		password = args[1]
	
	if not email.empty() and not password.empty():
		Network.auth(email, password)
	else:
		if cached:
			UI.error("Could not login from cached credentials.", self.name)
		else:
			UI.error("Could not login, please try again.", self.name)


func logout(_args:Array):
	Network.logout()


func cache(args:Array):
	if args.empty():
		UI.error("/cache expects at least 1 argument. (credentials, view)")
		return
	
	if args[0].to_upper() == "CREDENTIALS":
		Chat.Messages.info("Caching credentials...")
		
		if not Network.session:
			print("Nothing to cache")
			return
		
		var network_data = {
			"email": Cache.session.email,
			"password": Cache.session.password,
			"username": Cache.session.username
		}
		
		Chat.Messages.success("Credentials cached.")
		Cache.save_account(network_data.username, network_data)
	
	elif args[0].to_upper() == "VIEW":
		Chat.Messages.debug("Cache data: " + str(Cache.cache))
		
		var cache = Cache.load_cache()
		if cache.has("data"):
			Chat.Messages.debug("Cache: " + str(cache))
		


# Default way to host a chat room thing...
func host(args:Array):
	if args.empty():
		Network.connect_socket()
		yield(Network.socket, "connected")
		print("Passed")
		# Creating the default channel just for testing
		Network.create_channel()
		return
	
	var room_name = args[0]
	var type = args[1]
	var persist = args[2]
	var hidden = args[3]
	
	# Sanitizing... what does that even mean, right?
	Network.create_channel(room_name, type, persist, hidden)


# Connect to a server thing
func join():
	Network.create_socket()
	yield(Network.socket, "socket_connected")
	Network.create_channel()


# Using rpc...maybe ( if i cant figure out how to get Nakama to work )
func create_server():
	pass


# Using rpc...maybe ( if i cant figure out how to get Nakama to work )
func enter_server():
	pass



