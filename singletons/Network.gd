extends Node


var _client : NakamaClient
var _session : NakamaSession
var _socket : NakamaSocket
var _channel = NakamaRTAPI.Channel

# Repalce this using a global Cache instead
var session_email: String
var session_password : String
var session_username : String

var server_key = "defaultkey"
var server_ip = "54206f987a47.ngrok.io"
var server_port = 0

var _room : String = "default"
var _data : Dictionary = {}

signal received_channel_message(message, user)


func _ready():
	#Silently attempt to login to the cache credentials
	
	var credentials
	var cache = Cache.load_cache()
	
	if not cache:
		return
	else:
		credentials = cache.credentials
	
	
	if credentials.empty():
		UI.Chat.debug("Cached credentials are empty", self.name)
	
	if not credentials.email.empty() and not credentials.password.empty():
		Network.create_client()
		Network.auth(credentials.email, credentials.password)
	else:
		UI.Chat.debug("Cached credentials are invalid. Please try again.", self.name)

func _exit_tree():
	if _socket:
		_socket.close()


func create_client(ip=server_ip, port=server_port, key=server_key):
	# Manually modified Nakama create client method
	# If the port is 0, then ignore the port
	UI.Chat.debug("Creating client...", self.name)
	
	server_ip = ip
	server_port = port
	server_key = key
	
	_client = Nakama.create_client(key, ip, port)
	
	if _client:
		UI.Chat.debug("Client was created!", self.name)
		
		if port == 0:
			UI.Chat.debug("Server KEY: " + key, self.name)
			UI.Chat.debug("Server IP: " + ip, self.name)
		else:
			UI.Chat.debug("Server KEY: " + key, self.name)
			UI.Chat.debug("Server IP: " + ip + ":" + str(port), self.name)


func create_socket():
	UI.Chat.debug("Creating socket...", self.name)
	
	if !_client:
		UI.Chat.error("No client available to create a socket!", self.name)
		return
	else:
		_socket = Nakama.create_socket_from(_client)
	
	var connected : NakamaAsyncResult = yield(_socket.connect_async(_session), "completed")
	
	if connected.is_exception():
		UI.Chat.error("An error occured: %s" % connected, self.name)
	else:
		UI.Chat.debug("Socket connected successfully. " + str(_socket), self.name)
		
		_socket.connect("received_channel_message", self, "_receive_message")
		_socket.connect("received_matchmaker_matched", self, "_on_matchmaker_matched")


func create_channel(room:String="default", type:String=NakamaSocket.ChannelType.Room):
	UI.Chat.debug("Creating channel...", self.name)
	
	if !_socket:
		UI.Chat.error("Could not create a channelNot connected to a socket!", self.name)
		return
	else:
		_channel = yield(_socket.join_chat_async(room, NakamaSocket.ChannelType.Room), "completed")
	
	if _channel.is_exception():
		UI.Chat.error("An error occured: %s" % _channel)
		UI.Chat.info("Channel roomname: %s, Channel type: %s" % room % type)
	else:
		UI.Chat.debug("Created/joined Channel: name = %s, and type = %s" % room % type)


func _receive_message(msg):
	var message = JSON.parse(msg.content).result.msg
	var user = msg.username
	
	UI.Chat.debug("Received message: '%s', from: %s" % message % user, self.name)
	
	emit_signal("received_channel_message", message, user)


func send_message(msg:String):
	UI.Chat.debug("Sending message...", self.name)
	
	if !_socket:
		UI.Chat.error("You are not connected to a socket!", self.name)
		return
	
	if !_channel:
		UI.Chat.error("You are not connected to a channel!", self.name)
		return
	
	var _data = {
		"msg": msg
	}
	
	var message_ack : NakamaRTAPI.ChannelMessageAck = yield(_socket.write_chat_message_async(_channel.id, _data), "completed")
	
	if message_ack.is_exception():
		UI.Chat.error("An error occured: %s" % message_ack)
		return
	else:
		UI.Chat.debug("Message sent!", self.name)


func auth(email:String, password:String, username:String=""):
	UI.Chat.debug("Authenticating...", self.name)
	
	if !_client:
		UI.Chat.debug("No client available to create a session!")
		return
	
	session_email = email
	session_password = password
		
	if username.empty():
		_session = yield(_client.authenticate_email_async(email, password), "completed")		
	else:
		session_username = username
		_session = yield(_client.authenticate_email_async(email, password, username), "completed")
		
	
	if _session.is_exception():
		UI.Chat.debug("Something went wrong when creating a session: %s" % _session, self.name)
	else:
		UI.Chat.debug("Authenticated! Session OK", self.name)


func create_match(query="*", min_players=2, max_players=10):
	UI.Chat.debug("Creating match...", self.name)
	
	var matchmaker_ticket : NakamaRTAPI.MatchmakerTicket = yield(
		_socket.add_matchmaker_async(query, min_players, max_players),
		"completed"
	)
	
	if matchmaker_ticket.is_exception():
		UI.Chat.debug("An error occured: %s" % matchmaker_ticket, self.name)
	else:
		UI.Chat.debug("Got ticket: %s" % [matchmaker_ticket], self.name)


func _on_matchmaker_matched(p_matched : NakamaRTAPI.MatchmakerMatched):
	UI.Chat.debug("Match found!", self.name)
	UI.Chat.debug("Matched opponents: %s" % [p_matched.users], self.name)
	
	var joined_match : NakamaRTAPI.Match = yield(_socket.join_matched_async(p_matched), "completed")
	
	if joined_match.is_exception():
		UI.Chat.error("An error occured: %s" % joined_match, self.name)
	else:
		UI.Chat.debug("Joined match: %s" % [joined_match], self.name)




