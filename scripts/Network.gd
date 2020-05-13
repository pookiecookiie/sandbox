extends Node

# ==============================================================================
#
# Member Variables

var current_client : NakamaClient = null
var current_session : NakamaSession = null
var current_socket : NakamaSocket = null
var current_channel : NakamaRTAPI.Channel = null

var current_room : String = "testing"

var data : Dictionary = {}


func _exit_tree():
	if current_socket:
		current_socket.close()


func create_socket():
	current_socket = Nakama.create_socket_from(current_client)
	
	var connected : NakamaAsyncResult = yield(current_socket.connect_async(current_session), "completed")
	if connected.is_exception():
		UI.Chat.log_error("An error occured: %s" % connected)
		return
		
	UI.Chat.log_success("Socket connected.")
	current_socket.connect("received_channel_message", self, "_receive_message")
	


func create_channel():
	if !current_socket:
		UI.Chat.log_error("You are not connected to a socket!")
		return
	
	current_channel = yield(current_socket.join_chat_async(current_room, NakamaSocket.ChannelType.Room), "completed")
	if current_channel.is_exception():
		UI.Chat.log_error("An error occured: %s" % current_channel)
		return
	UI.Chat.log_success("Channel was created!")

func _receive_message(msg):
	var message = JSON.parse(msg.content).result.msg
	
	UI.Chat.receive_message(message, msg.username)


func send_message(msg:String):
	var data = {
		"msg": msg
	}
	
	var message_ack : NakamaRTAPI.ChannelMessageAck = yield(current_socket.write_chat_message_async(current_channel.id, data), "completed")
	if message_ack.is_exception():
		UI.Chat.log_error("An error occured: %s" % message_ack)
		return

	


func auth(email, password, username=null):
	current_client = Nakama.create_client("defaultkey", "192.168.99.100", 7350, "http")
	
	if username:
		current_session = yield(current_client.authenticate_email_async(email, password, username), "completed")
	else:
		current_session = yield(current_client.authenticate_email_async(email, password), "completed")


	if not current_session.is_exception():
		UI.Chat.log_success("Session OK")
		UI.Chat.set_username(current_session.username)
	else:
		UI.Chat.log_error("Something went wrong when creating a session (SIGN UP)")
		return
	
	








