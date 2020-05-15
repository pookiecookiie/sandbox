extends Node


#func _ready():
#	Network.connect("player_connected", self, "_player_connected")
#
#	var new_player = preload("res://scenes/world/Player/Player.tscn").instance()
#	new_player.name = str(get_tree().get_network_unique_id())
#	new_player.set_network_master(get_tree().get_network_unique_id())
#	add_child(new_player)
#
#
#func _player_connected(id):
#	var new_player = preload("res://scenes/world/Player/Player.tscn").instance()
#	new_player.name = str(id)
#	new_player.set_network_master(id)
#	add_child(new_player)
#
#	var users = []
#
#	for child in get_tree().get_root().get_node("main").get_children():
#		if child.name.is_valid_integer():
#			users.append("User_"+child.name)






