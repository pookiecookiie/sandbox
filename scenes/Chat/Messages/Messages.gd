extends RichTextLabel

# Could load messagesin here
var logs : Dictionary = {
	"debug": [], # write to a file
	"messages": [] # write to the server...maybe eventually
}


func get_timestamp():
	return {
		"hour": str(OS.get_time().hour).pad_zeros(2),
		"minute": str(OS.get_time().minute).pad_zeros(2),
		"second": str(OS.get_time().second).pad_zeros(2)
	}


func load_messages(source:Dictionary):
	# ONE TIME THING because its a bit slow
	bbcode_text = ""
	
	if source.size() < 1:
		return
	
	for message in source.values():
		var timestamp = get_timestamp()
		
		add_text("[" + timestamp.hour + ":" + timestamp.minute + ":" + timestamp.second + "] ")
		add_text("[" + message.messenger + "] ")
		add_text(message.text + "\n")


func append_log(text:String, messenger:String, chat:String):
	# Updates the history ONLY
	
	var message_id = str(logs.messages.size()+1)
	var message_key = "message_" + message_id
	
	logs.messages.append({
		"id": message_id, # "visual" identifier
		"timestamp": OS.get_time(), # When it was sent
		"text": text, # What was sent
		"messenger": messenger, # Who sent it
		"chat": chat # Where it was sent to
	})


func pop_history_log():

	pass


func append_text(text:String, settings:Dictionary={}):
	# Adds whatever text is passed in to the bb_code
	# If a color is specified, it will apply that color
	
	if !settings.has("text_color"):
		append_bbcode(text)
		newline()
	else:
		push_color(settings.text_color)
		append_bbcode(text)
		newline()
		pop()


func append_name(name:String, settings:Dictionary={}):
	# Will add a colon to the end of the name
	# Will NOT add brackets encapsulating the name
	if !settings.has("name_color"):
		append_bbcode(name + ": ")
	else:
		push_color(settings.name_color)
		append_bbcode(name + ": ")
		pop()


func append_tag(text:String, settings:Dictionary={}):
	# Will encapsulate the text with [] to simbolize a TAG
	
	if not settings.has("text_color") and not settings.has("tag_color"):
		append_bbcode("["+text+"] ")
	
	elif settings.has("text_color") and not settings.has("tag_color"):
		append_bbcode("[")
		
		push_color(settings.text_color)
		append_bbcode(text)
		pop()
		
		append_bbcode("] ")

	elif settings.has("text_color") and settings.has("tag_color"):
		push_color(settings.tag_color)
		append_bbcode("[")
		pop()
		
		push_color(settings.text_color)
		append_bbcode(text)
		pop()
		
		push_color(settings.tag_color)
		append_bbcode("] ")
		pop()


func debug(text:String, from:String=""):
	# Displays a DEBUG message
	# Only visible when UI>SETTINGS>DEBUG is true
	
	if !UI.settings.DEBUG:
		# Ignore debug messages when not debugging
		return
	
	var timestamp = get_timestamp()
	var timestamp_text = timestamp.hour + ":" + timestamp.minute + ":" + timestamp.second
	
	append_tag(timestamp_text, {
		"text_color": Color.pink,
		"tag_color": Color.white
	})
	
	append_tag("DEBUG", { # This could be represented by a color.........
		"text_color": Color.green,
		"tag_color": Color.white
	})
	
	append_name(from, {
		"name_color": Color.purple
	})
	
	append_text(text)


func say(text:String, messenger:String, chat:String):
	# This is going to be the default pattern for PEOPLE sending messages to the
	# chat. At least for now
	
	var timestamp = get_timestamp()
	var timestamp_text = timestamp.hour + ":" + timestamp.minute + ":" + timestamp.second
	append_tag(timestamp_text, {
		"text_color": Color.pink,
		"tag_color": Color.white
	})
	
	append_tag(chat, { # This could be represented by a color.........
		"text_color": Color.green,
		"tag_color": Color.white
	})
	
	append_name(messenger, {
		"name_color": Color.blue
	})
	
	
	append_text(text)
	
	# Send this to a file i guess? not sure if there is any use to it
	# var message_log += (timestamp_text + chat + messenger + text)
	
	append_log(text, messenger, chat)

