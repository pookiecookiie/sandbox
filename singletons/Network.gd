extends Node

# Can we modify these?
onready var client : NakamaClient = create_client()
onready var socket : NakamaSocket = create_socket()
var session : NakamaSession
var channel = NakamaRTAPI.Channel

var socket_connected = false

var server_key = "defaultkey"
var server_ip = "8ae725bbb307.ngrok.io"
var server_port = 0

var connected_opponents = {}
var room_users = {}

var room : String = "default"
var data : Dictionary = {} # player data that will be networked...possibly


signal authenticated(session)
signal received_chat_message(message, user, chat)

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
	
	var client = Nakama.create_client(key, ip, port)
	
	if client:
		UI.debug_success("Client was created!", self.name)
	
	return client


func create_socket():
	UI.debug("Creating socket...", self.name)
	
	if !client:
		UI.error("NO client available to create a socket!", self.name)
		return # Get out of here
	else:
		socket = Nakama.create_socket_from(client)
		
		if socket:
			UI.debug_success("Socket was created!", self.name)
	return socket


func connect_socket():
	var connected = yield(socket.connect_async(session), "completed")
	
	if connected.is_exception():
		UI.error("An error occured: %s" % connected, self.name)
		return # Get out of here
	else:
		UI.debug_success("Socket connected successfully. " + str(socket), self.name)
		
		# Connect to all necessary callbacks
		socket.connect("received_error", self, "_handle_socket_error")
		
		socket.connect("closed", self, "_socket_closed")
		socket.connect("connected", self, "_socket_connected")
		
		socket.connect("received_channel_message", self, "_received_channel_message")
		socket.connect("received_channel_presence", self, "_received_channel_presence")
		
		socket.connect("received_matchmaker_matched", self, "_on_matchmaker_matched")
		socket.connect("received_match_presence", self, "_received_match_presence")
		socket.connect("received_match_state", self, "_received_match_state")
	
	socket_connected = connected
	return connected


# SOCKET CALLBACKS
func _handle_socket_error(error):
	UI.error("An ERROR occurred: %s" % error)


func _socket_closed():
	UI.debug("Socket CLOSED.")


func _socket_connected():
	UI.debug("Socket CONNECTED.")


func _received_channel_message(msg):
	var message_data = JSON.parse(msg.content).result
	
	var message = message_data.msg
	var user = message_data.user
	var chat = message_data.chat
	emit_signal("received_chat_message", message, user, chat)


func _received_channel_presence(p_presence):
	UI.debug("Socket received channel presence.")
	UI.debug("Presence %s" % p_presence)
	
	for p in p_presence.joins:
		room_users[p.user_id] = p
	for p in p_presence.leaves:
		room_users.erase(p.user_id)
	print("Users in room: %s" % [room_users.keys()])


func _on_matchmaker_matched(p_matched):
	UI.debug_success("Socket matchmaker MATCHED.")
	UI.debug_success("Matched opponents: %s" % [p_matched.users], self.name)
	
	var joined_match : NakamaRTAPI.Match = yield(socket.join_matched_async(p_matched), "completed")
	
	if joined_match.is_exception():
		UI.error("An ERROR occured: %s" % [joined_match], self.name)
	else:
		UI.debug_success("Joined match: %s" % [joined_match], self.name)


func _received_match_presence(p_presence):
	UI.debug("Socket received match PRESENCE.")
	
	for p in p_presence.joins:
		connected_opponents[p.user_id] = p
	for p in p_presence.leaves:
		connected_opponents.erase(p.user_id)
	print("Connected opponents: %s" % [connected_opponents])


func _received_match_state(p_state):
	UI.debug("Socket received match STATE")
	
	print("Received match state with opcode %s, data %s" % [p_state.op_code, parse_json(p_state.data)])


# END SOCKET CALLBACKS


func create_channel(room:String="default", type=NakamaSocket.ChannelType.Room, persist=true, hidden=false):
	UI.debug("Creating channel...", self.name)
	
	if !socket:
		UI.error("You are NOT connected to a socket!", self.name)
		return
	else:
		channel = yield(socket.join_chat_async(room, type, true, false), "completed")
	
	if channel.is_exception():
		UI.error("An error occured: %s" % [channel], self.name)
		UI.error("roomname: [%s], type: [%s]" % [room, type], self.name)
		return
	
	UI.success("Created/joined Channel: name [%s], type [%s]" % [room, type], self.name)
	
	# Add users already present in chat room.
	for p in channel.presences:
		room_users[p.user_id] = p
	print("Users in room: %s" % [room_users.keys()])


func send_message(msg:String, from:String, chat:String):
	if !socket || !channel:
		UI.error("You are NOT connected to a socket or to a channel!", self.name)
		UI.error("Socket: %s, Channel: %s" % [socket, channel])
		return
	
	var message_data = {
		"msg": msg,
		"user": from,
		"chat": chat
	}
	
	var message_ack = yield(socket.write_chat_message_async(channel.id, message_data), "completed")
	
	if message_ack.is_exception():
		UI.error("An error occurred: %s" % message_ack, self.name)


func leave_chat():
	var channel_id = "<channel id>"
	var result : NakamaAsyncResult = yield(socket.leave_chat_async(channel_id), "completed")
	if result.is_exception():
		print("An error occured: %s" % result)
		return
	print("Left chat")


func chat_history():
	var channel_id = "<channel id>"
	var result : NakamaAPI.ApiChannelMessageList = yield(client.list_channel_messages_async(session, channel_id, 10), "completed")
	if result.is_exception():
		print("An error occured: %s" % result)
		return
	for m in result.messages:
		var message : NakamaAPI.ApiChannelMessage = m as NakamaAPI.ApiChannelMessage
		print("Message has id %s and content %s" % [message.message_id, message.content])
	print("Get the next page of messages with the cursor: %s" % [result.next_cursor])


func auth(email:String, password:String, username:String=""):
	UI.debug("Authenticating...", self.name)
	
	if !client:
		UI.error("NO client available to create a session!", self.name)
		return # Get out of here
		
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
	
	Cache.save_account(Cache.session.username, Cache.session)
	
	if session.is_exception():
		UI.error("Something went WRONG when creating a session: %s" % session, self.name)
	else:
		# Authenticated Successfully
		emit_signal("authenticated", session)

		UI.success("Authenticated!", self.name)


func logout():
	session = null
	channel = null
	

# MATCH
func get_matchmaker_ticket(query="*", min_players=2, max_players=10):
	UI.debug("Creating match...", self.name)
	
	var matchmaker_ticket : NakamaRTAPI.MatchmakerTicket = yield(
		socket.add_matchmaker_async(query, min_players, max_players),
		"completed"
	)
	
	if matchmaker_ticket.is_exception():
		UI.debug_error("An error occured: %s" % [matchmaker_ticket], self.name)
	else:
		UI.debug_success("Got ticket: %s" % [matchmaker_ticket], self.name)
		return matchmaker_ticket


func create_match():
	var created_match : NakamaRTAPI.Match = yield(socket.create_match_async(), "completed")
	if created_match.is_exception():
		print("An error occured: %s" % created_match)
		return
	print("New match with id %s.", created_match.match_id)


func join_match():
	var match_id = "<matchid>"
	var joined_match = yield(socket.join_match_async(match_id), "completed")
	if joined_match.is_exception():
		print("An error occured: %s" % joined_match)
		return
	for presence in joined_match.presences:
		print("User id %s name %s'." % [presence.user_id, presence.username])


func send_match_data():
	var match_id = "<matchid>"
	var op_code = 1
	var new_state = {"hello": "world"}
	socket.send_match_state_async(match_id, op_code, JSON.print(new_state))


func leave_match():
	var match_id = "<matchid>"
	var leave : NakamaAsyncResult = yield(socket.leave_match_async(match_id), "completed")
	if leave.is_exception():
		print("An error occured: %s" % leave)
		return
	print("Match left")


# END MATCH


# SOCIAL
func get_account():
	var account : NakamaAPI.ApiAccount = yield(client.get_account_async(session), "completed")
	if account.is_exception():
		print("An error occured: %s" % account)
		return # Get out of here
	
	var user = account.user
	print("User id '%s' and username '%s'." % [user.id, user.username])
	print("User's wallet: %s." % account.wallet)
	return account


func add_friend():
	var list : NakamaAPI.ApiFriendList = yield(client.list_friends_async(session), "completed")
	if list.is_exception():
		print("An error occured: %s" % list)
		return
	for f in list.friends:
		var friend = f as NakamaAPI.ApiFriend
		print("User %s, status %s" % [friend.user.id, friend.state])


func remove_friend():
	var ids = ["user-id1", "user-id2"]
	var usernames = ["username1"]
	var remove : NakamaAsyncResult = yield(client.delete_friends_async(session, ids, usernames), "completed")
	if remove.is_exception():
		print("An error occured: %s" % remove)
		return
	print("Remove friends: user ids %s, usernames %s" % [ids, usernames])


func block_friend():
	var ids = ["user-id1", "user-id2"]
	var usernames = ["username1"]
	var block : NakamaAsyncResult = yield(client.block_friends_async(session, ids, usernames), "completed")
	if block.is_exception():
		print("An error occured: %s" % block)
		return
	print("Remove friends: user ids %s, usernames %s" % [ids, usernames])


func list_groups():
	var list : NakamaAPI.ApiGroupList = yield(client.list_groups_async(session, "heroes*", 20), "completed")
	if list.is_exception():
		print("An error occured: %s" % list)
		return
	for g in list.groups:
		var group = g as NakamaAPI.ApiGroup
		print("Group: name %s, id %s", [group.name, group.id])


func join_group():
	var group_id = "<group id>"
	var join : NakamaAsyncResult = yield(client.join_group_async(session, group_id), "completed")
	if join.is_exception():
		print("An error occured: %s" % join)
		return
	print("Sent group join request %s" % group_id)


func list_user_groups():
	var user_id = "<user id>"
	var result : NakamaAPI.ApiUserGroupList = yield(client.list_user_groups_async(session, user_id), "completed")
	if result.is_exception():
		print("An error occured: %s" % result)
		return
	for ug in result.user_groups:
		var g = ug.group as NakamaAPI.ApiGroup
		print("Group %s role %s", g.id, ug.state)


func list_group_users():
	var group_id = "<group id>"
	var member_list : NakamaAPI.ApiGroupUserList = yield(client.list_group_users_async(session, group_id), "completed")
	if member_list.is_exception():
		print("An error occured: %s" % member_list)
		return
	for ug in member_list.group_users:
		var u = ug.user as NakamaAPI.ApiUser
		print("User %s role %s" % [u.id, ug.state])


func create_group():
	var group_name = "pizza-lovers"
	var group_desc = "pizza lovers, pineapple haters"
	var group : NakamaAPI.ApiGroup = yield(client.create_group_async(session, group_name, group_desc), "completed")
	if group.is_exception():
		print("An error occured: %s" % group)
		return
	print("New group: %s" % group)


func update_group():
	var group_id = "<group id>"
	var description = "Better than Marvel Heroes!"
	var update : NakamaAsyncResult = yield(client.update_group_async(session, group_id, null, description), "completed")
	if update.is_exception():
		print("An error occured: %s" % update)
		return
	print("Updated group")


func leave_group():
	var group_id = "<group id>"
	var leave : NakamaAsyncResult = yield(client.leave_group_async(session, group_id), "completed")
	if leave.is_exception():
		print("An error occured: %s" % leave)
		return
	print("Group left")


func accept_new_user():
	var group_id = "<group id>"
	var user_ids = ["<user id>"]
	var accept : NakamaAsyncResult = yield(client.add_group_users_async(session, group_id, user_ids), "completed")
	if accept.is_exception():
		print("An error occured: %s" % accept)
		return
	print("User added")


func promote_member():
	var group_id = "<group id>"
	var user_ids = ["<user id>"]
	var promote : NakamaAsyncResult = yield(client.promote_group_users_async(session, group_id, user_ids), "completed")
	if promote.is_exception():
		print("An error occured: %s" % promote)
		return
	print("User promoted")


func kick_member():
	var group_id = "<group id>"
	var user_ids = ["<user id>"]
	var kick : NakamaAsyncResult = yield(client.kick_group_users_async(session, group_id, user_ids), "completed")
	if kick.is_exception():
		print("An error occured: %s" % kick)
		return
	print("User kicked")


func remove_group():
	var group_id = "<group id>"
	var remove : NakamaAsyncResult = yield(client.delete_group_async(session, group_id), "completed")
	if remove.is_exception():
		print("An error occured: %s" % remove)
		return
	print("Group removed")


# END SOCIAL
