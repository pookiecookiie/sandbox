extends Node


var session : NakamaSession
var client : NakamaClient
var socket : NakamaSocket
var channel = NakamaRTAPI.Channel

var server_key = "defaultkey"
var server_ip = "4730e11e17d9.ngrok.io"
var server_port = 0

var room : String = "default"
var data : Dictionary = {}

signal authenticated(session)
signal socket_connected(socket)
signal joined_chat(channel)
signal received_channel_message(message, user)


func _ready():
	#Silently attempt to login to the cache credentials
	
	return # For testing...
	UI.info("Loading cache...", self.name)
	var cache = Cache.load_cache()
	var credentials

	if cache.empty() or not cache.has("accounts"):
		UI.error("Cache is empty or has no account to login.", self.name)
		return
	else:
		credentials = cache.accounts.bobo
	
	if not credentials.email.empty() and not credentials.password.empty():
		UI.info("Attempting to login...", self.name)
		Network.create_client()
		Network.auth(credentials.email, credentials.password)
	else:
		UI.error("Could not login, Credentials are invalid or empty!", self.name)


func _exit_tree():
	if socket:
		socket.close()


func create_client(ip=server_ip, port=server_port, key=server_key):
	# Manually modified Nakama create client method
	# If the port is 0, then ignore the port
	UI.debug("Creating client...", self.name)
	
	server_ip = ip
	server_port = port
	server_key = key
	
	client = Nakama.create_client(key, ip, port)
	
	if client:
		UI.debug_success("Client was created!", self.name)
		
		if port == 0:
			UI.debug("Server KEY: " + key, self.name)
			UI.debug("Server IP: " + ip, self.name)
		else:
			UI.debug("Server KEY: " + key, self.name)
			UI.debug("Server IP: " + ip + ":" + str(port), self.name)


func create_socket():
	UI.debug("Creating socket...", self.name)
	
	if !client:
		UI.error("NO client available to create a socket!", self.name)
		return
	else:
		socket = Nakama.create_socket_from(client)
	
	var connected : NakamaAsyncResult = yield(socket.connect_async(session), "completed")
	
	if connected.is_exception():
		UI.error("An error occured when trying to create a socket: %s" % connected, self.name)
	else:
		UI.success("Socket connected successfully. " + str(socket), self.name)
		
		
		emit_signal("socket_connected", socket)
		
		socket.connect("received_channel_message", self, "_receive_message")
		socket.connect("received_matchmaker_matched", self, "_on_matchmaker_matched")



func create_channel(room:String="default", type=NakamaSocket.ChannelType.Room):
	UI.debug("Creating channel...", self.name)
	
	if !socket:
		UI.error("You are NOT connected to a socket!", self.name)
		return
	else:
		channel = yield(socket.join_chat_async(room, type, true, false), "completed")
	
	if channel.is_exception():
		UI.error("An error occured hen Joining/creating a channel: %s" % [channel], self.name)
		UI.error("Channel roomname: %s, Channel type: %s" % [room, type], self.name)
	else:
		emit_signal("joined_chat", channel)
		UI.success("Created/joined Channel: name = %s, and type = %s" % [room, type], self.name)


func send_message(msg:String, from:String, chat:String):
	#UI.debug("Sending message...", self.name)
	
	if !socket:
		UI.error("You are NOT connected to a socket!", self.name)
		return
	
	if !channel:
		UI.error("You are NOT connected to a channel!", self.name)
		return
	
	var message_data = {
		"msg": msg,
		"user": from,
		"chat": chat
	}
	
	var message_ack : NakamaRTAPI.ChannelMessageAck = yield(socket.write_chat_message_async(channel.id, message_data), "completed")
	
	if message_ack.is_exception():
		UI.error("An error occurred when trying to send a message: %s" % message_ack, self.name)
	else:
		#UI.debug("Message sent!", self.name)
		pass


func _receive_message(msg):
	var message_data = JSON.parse(msg.content).result
	var message = message_data.msg
	var user = message_data.user
	var chat = message_data.chat
	
	emit_signal("received_channel_message", message, user, chat)
	
	#UI.debug("Received message: '%s', from: %s" % [message, user], self.name)


func auth(email:String, password:String, username:String=""):
	UI.debug("Authenticating...", self.name)
	
	if !client:
		UI.error("NO client available to create a session!", self.name)
		return
		
	if username.empty():
		session = yield(client.authenticate_email_async(email, password), "completed")
	else:
		session = yield(client.authenticate_email_async(email, password, username), "completed")
	
	Cache.save_session({
		"email": email,
		"password": password,
		"username": session.username,
		"session": session
	})
	
	UI.Chat.ChatBox.username = Cache.session.username
	
	if session.is_exception():
		UI.error("Something went WRONG when creating a session: %s" % session, self.name)
	else:
		# Authenticated Successfully
		emit_signal("authenticated", session)

		UI.success("Authenticated!", self.name)


func create_match(query="*", min_players=2, max_players=10):
	UI.debug("Creating match...", self.name)
	
	var matchmaker_ticket : NakamaRTAPI.MatchmakerTicket = yield(
		socket.add_matchmaker_async(query, min_players, max_players),
		"completed"
	)
	
	if matchmaker_ticket.is_exception():
		UI.debug_error("An error occured: %s" % [matchmaker_ticket], self.name)
	else:
		UI.debug_success("Got ticket: %s" % [matchmaker_ticket], self.name)


func _on_matchmaker_matched(p_matched : NakamaRTAPI.MatchmakerMatched):
	UI.debug_success("Match found!", self.name)
	UI.debug("Matched opponents: %s" % [p_matched.users], self.name)
	
	var joined_match : NakamaRTAPI.Match = yield(socket.join_matched_async(p_matched), "completed")
	
	if joined_match.is_exception():
		UI.error("An ERROR occured when joining the match: %s" % [joined_match], self.name)
	else:
		UI.success("Joined match: %s" % [joined_match], self.name)




