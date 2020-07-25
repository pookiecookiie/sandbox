extends Node


var accounts = {}
var data = {}
var session = {}


func _ready():
	var cache = load_cache()
	
	if cache.has("data") and cache.has("accounts"):
		data = cache.data
		accounts = cache.accounts


func _exit_tree():
	save_cache()


func save_session(session_to_save):
	session = session_to_save


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
	
	if data.empty() and accounts.empty():
		UI.info("Nothing to save.", self.name)
		return
	
	var cache = {
		"data": data,
		"accounts": accounts
	}
	
	# Store the save dictionary as a new line in the save file
	cache_file.store_line(to_json(cache))
	UI.info("Saved.")
	cache_file.close()


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
