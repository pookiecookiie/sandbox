extends Node


var data = {}


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# load the cache, save it to "data" for ease of access during the game
func get_data():
	pass


func save_cache(key:String, data:Dictionary):
	var cache_file = File.new()
	cache_file.open("user://cache.save", File.WRITE)
	
	var cache = {}
	
	cache[key] = data
	
	# Store the save dictionary as a new line in the save file
	cache_file.store_line(to_json(cache))
	cache_file.close()


func load_cache():
	var cache_file = File.new()
	if not cache_file.file_exists("user://cache.save"):
		return # Error! We don't have cache to load.
	
	var cached_data : Dictionary
	
	# Load the file line by line and process that dictionary to restore
	# the object it represents.
	cache_file.open("user://cache.save", File.READ)
	while cache_file.get_position() < cache_file.get_len():
		# Get the saved dictionary from the next line in the save file
		cached_data = parse_json(cache_file.get_line())
	
		
	cache_file.close()
	return cached_data
	
