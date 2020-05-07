extends ScrollContainer

# ==============================================================================
#
# Nodes

onready var CreateServerButton = $VBox/Inner/Buttons/CreateServer
onready var AddServerButton = $VBox/Inner/Buttons/AddServer
onready var ServerNameLineEdit = $VBox/ServerPrompt/VBox/ServerNameLineEdit
onready var IPLineEdit = $VBox/ServerPrompt/VBox/HBox/IP/IPLineEdit
onready var PortLineEdit = $VBox/ServerPrompt/VBox/HBox/Port/PortLineEdit
onready var ClientsLineEdit = $VBox/ServerPrompt/VBox/HBox/MaxClients/ClientsLineEdit

# ==============================================================================


# ==============================================================================
#
# Member Variables

const DEFAULT_NAME = "My awesome server"
const DEFAULT_IP = "127.0.0.1"
const DEFAULT_PORT = 42069
const MAX_CLIENTS = 5 # Max hamachi peers

# ==============================================================================


# ==============================================================================
#
# Godot functions

func _ready():
	CreateServerButton.connect("pressed", self, "create_server")
	AddServerButton.connect("pressed", self, "add_server")
	
	IPLineEdit.placeholder_text = DEFAULT_IP + ":" + str(DEFAULT_PORT)
	ClientsLineEdit.placeholder_text = str(MAX_CLIENTS)

# ==============================================================================


# ==============================================================================
#
# Utils

func create_server():
	if !IPLineEdit.text.empty() and IPLineEdit.text != "127.0.0.1":
		UI.Chat.log_error("Cannot create server using an external IP! please use localhost(127.0.0.1 default) as the server IP. Use hamachi or similars to play with your friends!")
		return
		
	var server_name : String = ServerNameLineEdit.text
	var port : String= PortLineEdit.text
	var max_clients : String = ClientsLineEdit.text
	
	# Use defaults if none were specified
	if server_name.empty():
		server_name = DEFAULT_NAME
	
	if port.empty():
		port = str(DEFAULT_PORT)
	
	if max_clients.empty():
		max_clients = str(MAX_CLIENTS)
	
	
	# Validate port and max number of clients
	if !port.is_valid_integer():
		UI.Chat.log_error("The port needs to be an available, unused port between 0 and 65535. Note that ports below 1024 are privileged and may require elevated permissions depending on the platform.")
		return
	
	if !max_clients.is_valid_integer() and int(max_clients) < 128:
		UI.Chat.log_error("Maximum number of clients MUST be a valid integer! (hamachi max clients is 5)")
		return
	
	# Store server data
	var server : Dictionary = {
		"name": server_name,
		"port": int(port),
		"max_clients": int(max_clients)
	}
	
	var err = Network.create_server(int(port), int(max_clients))
	if err == 20:
		UI.Chat.log_error("Have you created a server on this port already?")
	
	if err == OK:
		# Add this server
		UI.Lobby.ServerList.create_server(server)
	
		# Add this new server to the network servers
		Network.add_server(server)
		
		UI.Chat.log_server("Server created at localhost:" + port + ". With a maximum of => "+max_clients+" players." )


func add_server():
	var server_name : String = ServerNameLineEdit.text
	var ip : String = IPLineEdit.text
	var port : String= PortLineEdit.text
	var max_clients : String = ClientsLineEdit.text
	
	UI.Chat.add_log("Adding server: " + server_name + " " + ip + ":" + port + " " + str(max_clients))
	
	if server_name.empty():
		server_name = DEFAULT_NAME
	
	
	if !ip.is_valid_ip_address() and !ip.empty():
		UI.Chat.log_error("Please provide a valid IP ADDRESS (copy and past hamachi IPV4 of your friends here)")
		return
	
	if !port.is_valid_integer() and !port.empty():
		UI.Chat.log_error("The port needs to be an available, unused port between 0 and 65535. Note that ports below 1024 are privileged and may require elevated permissions depending on the platform.")
		return
	
	if !max_clients.is_valid_integer() and !max_clients.empty():
		UI.Chat.log_error("Maximum number of clients MUST be a valid integer! (hamachi max clients is 5)")
		return
	
	
	var server : Dictionary = {
		"name": server_name,
		"ip": ip,
		"port": int(port),
		"max_clients": int(max_clients)
	}
	
	# Add server to the network
	Network.add_server(server)
	
	# add this server to the list
	UI.Lobby.ServerList.add_server(server)



# ==============================================================================

