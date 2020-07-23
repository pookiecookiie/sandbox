extends RichTextLabel

enum CHAT_TYPES {
	LOCAL, # On the current match or place such as lobby
	GROUP, # Private group
	GLOBAL,
	DIRECT # Friend chat
}

# Could load messages in here
var logs : Dictionary = {
	"debug": [], # write to a file
	"messages": [], # write to the server...maybe.....
}

var current_chat_type = CHAT_TYPES.LOCAL


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


func push_log(which_log:String, text:String, kind:String, from:String, chat:String=""):
	# Updates the logs ONLY
	
	var message_id = str(logs.messages.size()+1)
	var message_key = "message_" + message_id
	
	logs[which_log].append({
		"id": message_id, # "visual" identifier
		"timestamp": OS.get_time(), # When it was sent
		"text": text, # What was sent
		"kind": kind, # What kind of message it was
		"from": from, # Who sent it
		"chat": chat # Where it was sent to, if direct message
	})


func pop_log(which_log:String):
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


func debug(text:String, from:String="CHAT"):
	# Displays a DEBUG message
	# Only visible when UI>SETTINGS>DEBUG is true
	var kind = "DEBUG"
	
	if !UI.settings.DEBUG:
		# Ignore debug messages when not debugging
		return
	
	var timestamp = get_timestamp()
	var timestamp_text = timestamp.hour + ":" + timestamp.minute + ":" + timestamp.second
	
	append_tag(timestamp_text, {
		"text_color": Color.pink,
		"tag_color": Color.white
	})
	
	append_tag(from, {
		"text_color": Color.whitesmoke,
		"tag_color": Color.white
	})
	
	append_name(kind, {
		"name_color": Color.purple
	})
	
	append_text(text)
	
	push_log("debug", text, kind, from)


func info(text:String, from:String="CHAT"):
	# This is going to be the default pattern for PEOPLE sending messages to the
	# chat. At least for now
	var kind = "INFO"
	
	var timestamp = get_timestamp()
	var timestamp_text = timestamp.hour + ":" + timestamp.minute + ":" + timestamp.second
	
	append_tag(timestamp_text, {
		"text_color": Color.orangered,
		"tag_color": Color.white
	})
	
	append_tag(from, { # This could be represented by a color.........
		"text_color": Color.whitesmoke,
		"tag_color": Color.white
	})
	
	append_name(kind, {
		"name_color": Color.lightblue
	})
	
	
	append_text(text)
	
	# Send this to a file i guess? not sure if there is any use to it
	# var message_log += (timestamp_text + chat + messenger + text)
	
	push_log("messages", text, kind, from)


func success(text:String, from:String="CHAT"):
	# This is going to be the default pattern for PEOPLE sending messages to the
	# chat. At least for now
	var kind = "SUCCESS"
	
	var timestamp = get_timestamp()
	var timestamp_text = timestamp.hour + ":" + timestamp.minute + ":" + timestamp.second
	append_tag(timestamp_text, {
		"text_color": Color.pink,
		"tag_color": Color.white
	})
	
	append_tag(from, { # This could be represented by a color.........
		"text_color": Color.whitesmoke,
		"tag_color": Color.white
	})
	
	append_name(kind, {
		"name_color": Color.green
	})
	
	
	append_text(text)
	
	# Send this to a file i guess? not sure if there is any use to it
	# var message_log += (timestamp_text + chat + messenger + text)
	
	push_log("messages", text, kind, from)


func error(text:String, from:String="CHAT"):
	# This is going to be the default pattern for PEOPLE sending messages to the
	# chat. At least for now
	var kind = "ERROR"
	
	var timestamp = get_timestamp()
	var timestamp_text = timestamp.hour + ":" + timestamp.minute + ":" + timestamp.second
	append_tag(timestamp_text, {
		"text_color": Color.pink,
		"tag_color": Color.white
	})
	
	append_tag(from, { # This could be represented by a color.........
		"text_color": Color.whitesmoke,
		"tag_color": Color.white
	})
	
	append_name(kind, {
		"name_color": Color.red
	})
	
	
	append_text(text)
	
	# Send this to a file i guess? not sure if there is any use to it
	# var message_log += (timestamp_text + chat + messenger + text)
	
	push_log("messages", text, kind, from)


func say(text:String, from:String, chat:String):
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
	
	append_name(from, {
		"name_color": Color.blue
	})
	
	
	append_text(text)
	
	# Send this to a file i guess? not sure if there is any use to it
	# var message_log += (timestamp_text + chat + messenger + text)
	
	push_log("messages", text, chat, from)

