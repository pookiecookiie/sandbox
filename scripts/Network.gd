extends Node

const DEFAULT_IP = "127.0.0.1"
const DEFAULT_PORT = 42069
const MAX_CLIENTS = 5

var players = []

signal player_connected
signal player_disconnected
signal connected_to_server
signal connection_failed
signal server_disconnected


func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")


func create_server(port:int=DEFAULT_PORT, max_clients:int=MAX_CLIENTS):
	var peer = NetworkedMultiplayerENet.new()
	var err = peer.create_server(port, max_clients)
	get_tree().set_network_peer(peer)
	
	return err


func join_server(ip:String=DEFAULT_IP, port:int=DEFAULT_PORT):
	var peer = NetworkedMultiplayerENet.new()
	var err = peer.create_client(ip, port)
	get_tree().set_network_peer(peer)
	
	return err


func _player_connected(id):
	players.append({"username": "User_"+str(id)})
	UI.Chat.Log("Player Connected " + str(id))
	UI.Chat.Log("Players Online: " + str(players))
	
	get_tree().change_scene("res://scenes/world/World.tscn")
	emit_signal("player_connected", id)

func _player_disconnected(id):
	for player in players:
		if player.username == "User_"+str(id):
			players.erase(player)
	
	UI.Chat.Log("Player Disconnected " + str(id))
	UI.Chat.Log("Players Online: " + str(players))
	
	emit_signal("player_disconnected", id)

func _connected_ok():
	UI.Chat.Log("Connection Ok", "NETWORK")
	get_tree().change_scene("res://scenes/world/World.tscn")
	emit_signal("connected_to_server")

func _connected_fail():
	UI.Chat.Log("Connection failed")
	emit_signal("connection_failed")

func _server_disconnected():
	UI.Chat.Log("Server Disconnected")
	emit_signal("server_disconnected")

