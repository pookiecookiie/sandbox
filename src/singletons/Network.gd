extends Node

# ==============================================================================
#
# Member Variables

var _client : NakamaClient = null
var _session : NakamaSession = null
var _socket : NakamaSocket = null
var _channel : NakamaRTAPI.Channel = null

var _room : String = ""
var data : Dictionary = {}

signal received_channel_message(message, user)


func _exit_tree():
	if _socket:
		_socket.close()


func create_client(ip="127.0.0.1", port=7350, key="nakama_godot_demo"):
	_client = Nakama.create_client(key, ip, port)
	
	if _client:
		UI.Chat.log_success("Client was created!")
		
		if port == -1:
			UI.Chat.log_info("Server KEY: " + key)
			UI.Chat.log_info("Server IP: " + ip)
			return
		
		UI.Chat.log_info("Server KEY: " + key)
		UI.Chat.log_info("Server IP: " + ip + ":" + str(port))


func create_socket():
	if !_client:
		UI.Chat.log_error("No client available to create a socket!")
		return
	
	_socket = Nakama.create_socket_from(_client)
	
	var connected : NakamaAsyncResult = yield(_socket.connect_async(_session), "completed")
	if connected.is_exception():
		UI.Chat.log_error("An error occured: %s" % connected)
		return
	
	UI.Chat.log_success("Socket connected. " + str(_socket))
	_socket.connect("received_channel_message", self, "_receive_message")


func create_channel(room="default"):
	if !_socket:
		UI.Chat.log_error("You are not connected to a socket!")
		return
	
	_channel = yield(_socket.join_chat_async(room, NakamaSocket.ChannelType.Room), "completed")
	if _channel.is_exception():
		UI.Chat.log_error("An error occured: %s" % _channel)
		return
	UI.Chat.log_success("Channel was created!")


func _receive_message(msg):
	var message = JSON.parse(msg.content).result.msg
	var user = msg.username
	emit_signal("received_channel_message", message, user)


func send_message(msg:String):
	if !_socket:
		UI.Chat.log_error("You are not connected to a socket!")
		return
	
	var data = {
		"msg": msg
	}
	
	var message_ack : NakamaRTAPI.ChannelMessageAck = yield(_socket.write_chat_message_async(_channel.id, data), "completed")
	if message_ack.is_exception():
		UI.Chat.log_error("An error occured: %s" % message_ack)
		return


func auth(email, password, username=null):
	if !_client:
		UI.Chat.log_error("No client available to create a session!")
		return
	
	if username:
		_session = yield(_client.authenticate_email_async(email, password, username), "completed")
	else:
		_session = yield(_client.authenticate_email_async(email, password), "completed")


	if not _session.is_exception():
		UI.Chat.log_success("Session OK")
		UI.Chat.set_username(_session.username)
	else:
		UI.Chat.log_error("Something went wrong when creating a session %s" % _session)
		return


func create_match():
	pass







