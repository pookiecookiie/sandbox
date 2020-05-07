extends ScrollContainer


var servers = {}

# ==============================================================================
#
# Utilis

func create_server(new_server):
	var server_info = load("res://scenes/ui/Lobby/scenes/ServerInfo.tscn").instance()
	server_info.set_name(new_server.name)
	server_info.set_ip("127.0.0.1")
	server_info.set_port(new_server.port)
	server_info.set_clients(new_server.max_clients)
	$List.add_child(server_info)

func add_server(new_server):
	var server_info = load("res://scenes/ui/Lobby/scenes/ServerInfo.tscn").instance()
	server_info.set_name(new_server.name)
	server_info.set_ip(new_server.ip)
	server_info.set_port(new_server.port)
	server_info.set_clients(new_server.max_clients)
	$List.add_child(server_info)
	
	servers[new_server.name] = server_info


func remove_server(server_name):
	servers.erase(server_name)


func edit_server(server_name, edited_server):
	servers[server_name].edit(edited_server)


func select(server_name):
	for child in $List.get_children():
		if child.name == server_name:
			child.select()
			return
	
	#Could not select?
	

# ==============================================================================
