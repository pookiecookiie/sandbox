extends Node

# ==============================================================================
#
# Member Variables

var _client = null
var _session : NakamaSession
var _socket = null
var _channel = null

var session_email: String
var session_password : String
var session_username : String

var _room : String = "default"
var _data : Dictionary = {}

signal received_channel_message(message, user)


func _exit_tree():
	if _socket:
		_socket.close()


func create_client(ip, port, key="defaultkey"):
	_client = Nakama.create_client(key, ip, port)
	
	if _client:
		UI.Chat.debug("Client was created!", "create_client")
		
		if port == 0:
			UI.Chat.debug("Server KEY: " + key)
			UI.Chat.debug("Server IP: " + ip)
			return
		
		UI.Chat.debug("Server KEY: " + key)
		UI.Chat.debug("Server IP: " + ip + ":" + str(port))


func create_socket():
	if !_client:
		UI.Chat.debug("No client available to create a socket!")
		return
	
	_socket = Nakama.create_socket_from(_client)
	
	var connected : NakamaAsyncResult = yield(_socket.connect_async(_session), "completed")
	if connected.is_exception():
		UI.Chat.debug("An error occured: %s" % connected)
		return
	
	UI.Chat.debug("Socket connected. " + str(_socket))
	
	# Listen for messages received through the socket
	# Listen for matches 
	_socket.connect("received_channel_message", self, "_receive_message")
	_socket.connect("received_matchmaker_matched", self, "_on_matchmaker_matched")


func create_channel(room="default"):
	if !_socket:
		UI.Chat.log_error("You are not connected to a socket!")
		return
	
	_channel = yield(_socket.join_chat_async(room, NakamaSocket.ChannelType.Room), "completed")
	
	if _channel.is_exception():
		UI.Chat.log_error("An error occured: %s" % _channel)
		return
	UI.Chat.debug("Channel was created!")


func _receive_message(msg):
	var message = JSON.parse(msg.content).result.msg
	var user = msg.username
	emit_signal("received_channel_message", message, user)


func send_message(msg:String):
	if !_socket:
		UI.Chat.debug("You are not connected to a socket!")
		return
	
	var _data = {
		"msg": msg
	}
	
	var message_ack : NakamaRTAPI.ChannelMessageAck = yield(_socket.write_chat_message_async(_channel.id, _data), "completed")
	if message_ack.is_exception():
		UI.Chat.debug("An error occured: %s" % message_ack)
		return


func auth(email, password, username=null):
	if !_client:
		UI.Chat.debug("No client available to create a session!")
		return
	
	if username:
		session_email = email
		session_password = password
		session_username = username
		
		_session = yield(_client.authenticate_email_async(email, password, username), "completed")
	else:
		session_email = email
		session_password = password
		
		_session = yield(_client.authenticate_email_async(email, password), "completed")


	if not _session.is_exception():
		UI.Chat.debug("Session OK")
		UI.Chat.debug(_session.username)
	else:
		UI.Chat.debug("Something went wrong when creating a session %s" % _session)
		return


func create_match(query="*", min_players=2, max_players=2):
	var matchmaker_ticket : NakamaRTAPI.MatchmakerTicket = yield(
		_socket.add_matchmaker_async(query, min_players, max_players),
		"completed"
	)
	if matchmaker_ticket.is_exception():
		UI.Chat.debug("An error occured: %s" % matchmaker_ticket)
		return
	UI.Chat.debug("Got ticket: %s" % [matchmaker_ticket])


func _on_matchmaker_matched(p_matched : NakamaRTAPI.MatchmakerMatched):
	UI.Chat.debug("Received MatchmakerMatched message: %s" % [p_matched])
	UI.Chat.debug("Matched opponents: %s" % [p_matched.users])
	var joined_match : NakamaRTAPI.Match = yield(_socket.join_matched_async(p_matched), "completed")
	if joined_match.is_exception():
		UI.Chat.debug("An error occured: %s" % joined_match)
		return
	UI.Chat.debug("Joined match: %s" % [joined_match])




