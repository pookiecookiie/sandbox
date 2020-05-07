extends MarginContainer


onready var ServerName = $Inner/VBox/Header/ServerName
onready var ServerIP = $Inner/VBox/IPRow/IP
onready var ServerClients = $Inner/VBox/ClientsRow/Clients

var ip : String
var port : int
var max_clients : int

var server = {}


func _ready():
	ServerName.text = name
	ServerIP.text = ip + ":" + str(port)
	ServerClients.text = str(max_clients)


func set_ip(_ip:String):
	ip = _ip

func set_port(_port:int):
	port = _port

func set_clients(_clients:int):
	max_clients = _clients


func edit(edited_server):
	if edited_server.name.empty():
		return UI.Chat.__say("Did not edit server...")
		
	if !edited_server.ip.is_valid_ip_address():
		return UI.Chat.__say("Did not edit server...")
		
	if !edited_server.port.is_valid_integer():
		return UI.Chat.__say("Did not edit server...")
		
	
	server = edited_server


func select():
	var a : Button = $Background
