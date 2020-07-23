extends Node

var credentials : Dictionary = {}


func save_credentials():
	if Network._session:
		return {
			"email": Network.session_email,
			"password": Network.session_password,
			"username": Network.session_username
		}


func cache_credentials():
	var cache_credentials = File.new()
	cache_credentials.open("user://cache_credentials.save", File.WRITE)

	# Check the node has a save function
	if !has_method("save_credentials"):
		print("persistent node '%s' is missing a save() function, skipped" % name)

	# Call the node's save function
	credentials = save_credentials()

	# Store the save dictionary as a new line in the save file
	cache_credentials.store_line(to_json(credentials))
	cache_credentials.close()
	
	# Reset the credentials once they are saved
	credentials = {}


func load_cache_credentials():
	var cache_credentials = File.new()
	if not cache_credentials.file_exists("user://cache_credentials.save"):
		return # Error! We don't have cache to load.
		
	# Load the file line by line and process that dictionary to restore
	# the object it represents.
	cache_credentials.open("user://cache_credentials.save", File.READ)
	while cache_credentials.get_position() < cache_credentials.get_len():
		# Get the saved dictionary from the next line in the save file
		var cached_credentials = parse_json(cache_credentials.get_line())
		credentials = cached_credentials
		
	cache_credentials.close()
	
	# Once the credentials have been saved do not store them here (no purpose)
	var credential_buffer = credentials
	credentials = {}
	
	return credential_buffer
