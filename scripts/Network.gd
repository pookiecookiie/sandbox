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


func connect_socket():
	UI.Chat.log_say(str(current_client))
	current_socket = Nakama.create_socket_from(current_client)
	
	var connected : NakamaAsyncResult = yield(current_socket.connect_async(current_session), "completed")
	if connected.is_exception():
		print("An error occured: %s" % connected)
		return
	UI.Chat.log_success("Socket connected.")
	
	current_socket.connect("received_channel_message", self, "_receive_message")
	
	
	current_channel = yield(current_socket.join_chat_async(current_room, NakamaSocket.ChannelType.Room), "completed")
	if current_channel.is_exception():
		UI.Chat.log_error("An error occured: %s" % current_channel)
		return


func _receive_message(msg):
	#UI.Chat.log_success("Received message!")
	#UI.Chat.log_success(JSON.parse(msg.content).result.msg)
	UI.Chat.send_message(JSON.parse(msg.content).result.msg, JSON.parse(msg.content).result.sender)


func send_message(msg:String):
	var data = {
		"sender": "someone",
		"msg": msg
	}
	
	var message_ack : NakamaRTAPI.ChannelMessageAck = yield(current_socket.write_chat_message_async(current_channel.id, data), "completed")
	if message_ack.is_exception():
		print("An error occured: %s" % message_ack)
		return
	#UI.Chat.log_success("Sent message %s" % [message_ack])
	


func sign_up(email, password, username):
	var STORE_FILE = "user://store.ini"
	var STORE_SECTION = "nakama"
	var STORE_KEY = "session"
	
	current_client = Nakama.create_client("defaultkey", "127.0.0.1", 7350, "http")
	
	var cfg = ConfigFile.new()
	cfg.load(STORE_FILE)
	var token = cfg.get_value(STORE_SECTION, STORE_KEY, "")
	
	if token:
		var restored_session = NakamaClient.restore_session(token)
		if restored_session.valid and not restored_session.expired:
			current_session = restored_session
			UI.Chat.log_success("Session restored.")
			return
	
	var deviceid = OS.get_unique_id() # This is not supported by Godot in HTML5, use a different way to generate an id, or a different authentication option.
	current_session = yield(current_client.authenticate_email_async(email, password, username, true), "completed")
	
	if not current_session.is_exception():
		cfg.set_value(STORE_SECTION, STORE_KEY, current_session.token)
		cfg.save(STORE_FILE)
	else:
		UI.Chat.log_error("Something went wrong when creating a session (SIGN UP)")
	
	UI.Chat.log_success("Session OK")
	connect_socket()


func sign_in(email="test@email.com", password="420potato"):
	var STORE_FILE = "user://store.ini"
	var STORE_SECTION = "nakama"
	var STORE_KEY = "session"
	
	
	current_client = Nakama.create_client("defaultkey", "127.0.0.1", 7350, "http")
	
	var cfg = ConfigFile.new()
	cfg.load(STORE_FILE)
	var token = cfg.get_value(STORE_SECTION, STORE_KEY, "")
	
	if token:
		var restored_session = NakamaClient.restore_session(token)
		if restored_session.valid and not restored_session.expired:
			current_session = restored_session
			UI.Chat.log_success("Session restored.")
			return
	
	var deviceid = OS.get_unique_id() # This is not supported by Godot in HTML5, use a different way to generate an id, or a different authentication option.
	current_session = yield(current_client.authenticate_email_async(email, password), "completed")
	
	if not current_session.is_exception():
		cfg.set_value(STORE_SECTION, STORE_KEY, current_session.token)
		cfg.save(STORE_FILE)
	else:
		UI.Chat.log_error("Something went wrong when creating a session (SIGN UP)")
	
	UI.Chat.log_success("Session OK")


