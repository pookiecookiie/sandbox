extends Node

# ==============================================================================
#
# Member Variables

var client : NakamaClient = null
var session : NakamaSession = null
var socket : NakamaSocket = null
var channel : NakamaRTAPI.Channel = null

var room : String = "testing"

var data : Dictionary = {}

signal received_channel_message(message, user)


func _exit_tree():
	if socket:
		socket.close()


func create_client(ip="127.0.0.1", port=7350, key="nakama_godot_demo"):
	client = Nakama.create_client(key, ip, port)
	if client:
		UI.Chat.log_success("seems like it works. " + str(client))


func create_socket():
	if !client:
		UI.Chat.log_error("There is no client to create the socket. " + str(client))
		return
	
	socket = Nakama.create_socket_from(client)
	UI.Chat.log_success("Socket connected. " + str(socket))
	socket.connect("received_channel_message", self, "_receive_message")
	
	var connected : NakamaAsyncResult = yield(socket.connect_async(session), "completed")
	if connected.is_exception():
		UI.Chat.log_error("An error occured: %s" % connected)
		return



func create_channel():
	if !socket:
		UI.Chat.log_error("You are not connected to a socket!")
		return
	
	channel = yield(socket.join_chat_async(room, NakamaSocket.ChannelType.Room), "completed")
	if channel.is_exception():
		UI.Chat.log_error("An error occured: %s" % channel)
		return
	UI.Chat.log_success("Channel was created!")


func _receive_message(msg):
	var message = JSON.parse(msg.content).result.msg
	var user = msg.username
	emit_signal("received_channel_message", message, user)


func send_message(msg:String):
	var data = {
		"msg": msg
	}
	
	var message_ack : NakamaRTAPI.ChannelMessageAck = yield(socket.write_chat_message_async(channel.id, data), "completed")
	if message_ack.is_exception():
		UI.Chat.log_error("An error occured: %s" % message_ack)
		return


func auth(email, password, username=null):
	if username:
		session = yield(client.authenticate_email_async(email, password, username), "completed")
	else:
		session = yield(client.authenticate_email_async(email, password), "completed")


	if not session.is_exception():
		UI.Chat.log_success("Session OK")
		UI.Chat.set_username(session.username)
	else:
		UI.Chat.log_error("Something went wrong when creating a session " + str(session))
		return









