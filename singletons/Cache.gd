extends Node


var cache = {}

var accounts = {}
var data = {}
var session = {}
var messages = {}


func _ready():
	cache = load_cache()
	
	if !cache.empty():
		data = cache.data
		accounts = cache.accounts
		session = cache.session
		messages = cache.messages


func _exit_tree():
	save_cache()


func save_session(session_to_save):
	session = session_to_save


func save_message(message):
	messages[message.id] = {
		"id": message.id, # "visual" identifier
		"timestamp": OS.get_time(), # When it was sent
		"text": message.text, # What was sent
		"kind": message.kind, # What kind of message it was
		"from": message.from, # Who sent it
		"chat": message.chat # Where it was sent to, if direct message
	}


func save_account(account_key:String, account_to_save):
	accounts[account_key] = account_to_save


func get_account(account_key:String):
	return accounts[account_key]


func erase_account(account_key:String):
	accounts.erase(account_key)


# Saves data to the data member, which will be saved to a file later
func save_data(key:String, data_to_save):
	data[key] = data_to_save


# Loads data from the data member
func get_data(key:String):
	return data[key]


func erase_data(key:String):
	data.erase(key)


func save_cache():
	UI.info("Saving cache...", self.name)
	
	var cache_file = File.new()
	cache_file.open("user://cache.save", File.WRITE)
	
	var _cache = {
		"data": data,
		"accounts": accounts,
		"session": session,
		"messages": messages
	}
	
	# Store the save dictionary as a new line in the save file
	cache_file.store_line(to_json(cache))
	cache_file.close()
	
	UI.info("Cache Saved.")
	return _cache


func load_cache():
	UI.info("Loading cache...", self.name)
	
	var cache_file = File.new()
	if not cache_file.file_exists("user://cache.save"):
		UI.debug_error("Cached file does not exist")
		return {} # Error! We don't have cache to load.
	
	var cached_data : Dictionary = {}
	
	# Load the file line by line and process that dictionary to restore
	# the object it represents.
	cache_file.open("user://cache.save", File.READ)
	while cache_file.get_position() < cache_file.get_len():
		# Get the saved dictionary from the next line in the save file
		cached_data = parse_json(cache_file.get_line())
	
	cache_file.close()
	
	UI.info("Cache loaded!", self.name)
	return cached_data
