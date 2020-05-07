extends Node

# ==============================================================================
#
# Member Variables

const DEFAULT_IP : String = "127.0.0.1"
const DEFAULT_PORT : int = 42069
const MAX_CLIENTS : int = 5

var servers = {}
var player_info = {}

# ==============================================================================


# ==============================================================================
#
# Network Signals

signal player_connected
signal player_disconnected
signal connected_to_server
signal connection_failed
signal server_disconnected

# ==============================================================================


# ==============================================================================
#
# Godot Functions

func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")

# ==============================================================================


# ==============================================================================
#
# Methods

func create_server(port=DEFAULT_PORT, max_clients=MAX_CLIENTS):
	var peer = NetworkedMultiplayerENet.new()
	var err = peer.create_server(port, max_clients)
	get_tree().network_peer = peer
	
	if err != OK:
		UI.Chat.log_error("Could not create server on port " + str(port) + " [ERR "+str(err)+"]")
	
	return err


func join_server(ip=DEFAULT_IP, port=DEFAULT_PORT):
	var peer = NetworkedMultiplayerENet.new()
	var err = peer.create_client(ip, port)
	get_tree().network_peer = peer
	
	if err != OK:
		UI.Chat.log_error("Could not join server " + ip+":"+str(port) + " [ERR "+str(err)+"]")
	
	return err


func add_server(server:Dictionary):
	servers[server.name] = server


func remove_server(server:Dictionary):
	servers.erase(server.name)


func edit_server(server, edited_server:Dictionary):
	servers[server.name] = edited_server


# ==============================================================================
#
# Networking functions 

remote func pre_configure_game():
	get_tree().set_pause(true)
	
	var selfPeerID = get_tree().get_network_unique_id()
	
	# Load world
	var world = load("res://scenes/world/World.tscn").instance()
	get_node("/root").add_child(world)

	# Load my player
	var my_player = preload("res://scenes/world/Player/Player.tscn").instance()
	my_player.set_name(str(selfPeerID))
	my_player.set_network_master(selfPeerID) # Will be explained later
	get_node("/root/world/players").add_child(my_player)

	# Load other players
	for p in player_info:
		var player = preload("res://scenes/world/Player/Player.tscn").instance()
		player.set_name(str(p))
		player.set_network_master(p) # Will be explained later
		get_node("/root/world/players").add_child(player)

	# Tell server (remember, server is always ID=1) that this peer is done pre-configuring.
	rpc_id(1, "done_preconfiguring", selfPeerID)


var players_done = []

remote func done_preconfiguring(who):
	# Here are some checks you can do, for example
	assert(get_tree().is_network_server())
	assert(who in player_info) # Exists
	assert(not who in players_done) # Was not added yet

	players_done.append(who)

	if players_done.size() == player_info.size():
		rpc("post_configure_game")

remote func post_configure_game():
	get_tree().set_pause(false)
	UI.Chat.__say("Game Started!")
# ==============================================================================


# ==============================================================================
#
# Signal Handlers

func _player_connected(id):
	UI.Chat.log_warning("Player Connected " + str(id))
	
	player_info[id] = {"username": "User_" + str(id)}
	pre_configure_game()
	
	emit_signal("player_connected", id)


func _player_disconnected(id):
	UI.Chat.log_warning("Player Disconnected " + str(id))
	
	player_info.erase(id)

	emit_signal("player_disconnected", id)


func _connected_ok():
	UI.Chat.log_warning("Connected OK.")
	
	emit_signal("connected_to_server")


func _connected_fail():
	UI.Chat.log_warning("Connection failed.")
	
	emit_signal("connection_failed")


func _server_disconnected():
	UI.Chat.log_warning("Server Disconnected.")
	
	emit_signal("server_disconnected")


# ==============================================================================





