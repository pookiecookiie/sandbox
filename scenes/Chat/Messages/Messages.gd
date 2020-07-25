extends RichTextLabel

enum CHAT_TYPES {
	LOCAL, # On the current match or place such as lobby
	GROUP, # Private group
	GLOBAL,
	DIRECT # Friend chat
}

onready var Chat = get_parent()

# Could load messages in here
var logs : Dictionary = {
	"debug": [], # write to a file
	"messages": [], # write to the server...maybe.....
}

var current_chat_type = CHAT_TYPES.LOCAL


func _ready():
	Network.connect("received_channel_message", self, "received_channel_message")


func received_channel_message(text, user, chat):
	if user == Chat.ChatBox.username:
		return
	say(text, user, chat)


func sort_ascending(a, b):
	var time = a.timestamp.hour


func load_messages(source:Dictionary):
	# ONE TIME THING because its a bit slow
	bbcode_text = ""
	
	if source.size() < 1:
		return
	
	for message in source.values():
		var messages : Array = []
		messages.sort_custom(self, "sort_ascending")


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


func append_from(name:String, settings:Dictionary={}):
	# Will add a colon to the end of the name
	# Will NOT add brackets encapsulating the name
	if !settings.has("text_color"):
		append_bbcode(name + ": ")
	else:
		push_color(settings.text_color)
		append_bbcode(name + ": ")
		pop()


func append_timestamp():
	var timestamp_raw = {
		"hour": str(OS.get_time().hour).pad_zeros(2),
		"minute": str(OS.get_time().minute).pad_zeros(2),
		"second": str(OS.get_time().second).pad_zeros(2)
	}
	var timestamp = timestamp_raw.hour + ":" + timestamp_raw.minute + ":" + timestamp_raw.second
	append_tag(timestamp, {
		"text_color": Color.orangered,
		"tag_color": Color.white
	})


func append_chat_tag(chat):
	append_tag(chat, {
		"text_color": Color.green,
		"tag_color": Color.white
	})

func append_debug_tag():
	append_tag("DEBUG", {
		"text_color": Color.indigo,
		"tag_color": Color.white
	})


func append_info_tag():
	append_tag("INFO", {
		"text_color": Color.whitesmoke,
		"tag_color": Color.white
	})


func append_success_tag():
	append_tag("SUCCESS", {
		"text_color": Color.green,
		"tag_color": Color.white
	})


func append_error_tag():
	append_tag("ERROR", {
		"text_color": Color.red,
		"tag_color": Color.white
	})


func debug(text:String, from:String="CHAT"):
	# Displays a DEBUG message
	# Only visible when UI>SETTINGS>DEBUG is true
	var kind = "DEBUG"
	
	append_timestamp()
	
	append_debug_tag()
	
	append_from(from, {
		"text_color": Color.whitesmoke,
		"tag_color": Color.white
	})
	
	append_text(text, {
		"text_color": Color.whitesmoke
	})
	
	push_log("debug", text, kind, from)


func debug_info(text:String, from:String="CHAT"):
	# Displays a DEBUG message
	# Only visible when UI>SETTINGS>DEBUG is true
	var kind = "INFO"
	
	append_timestamp()
	
	append_debug_tag()
	
	append_from(from, {
		"text_color": Color.whitesmoke,
		"tag_color": Color.white
	})
	
	append_text(text, {
		"text_color": Color.white
	})
	
	push_log("debug", text, kind, from)


func debug_success(text:String, from:String="CHAT"):
	# Displays a DEBUG message
	# Only visible when UI>SETTINGS>DEBUG is true
	var kind = "SUCCESS"
	
	append_timestamp()
	
	append_debug_tag()
	
	append_from(from, {
		"text_color": Color.whitesmoke,
		"tag_color": Color.white
	})
	
	append_text(text, {
		"text_color": Color.lightgreen
	})
	
	push_log("debug", text, kind, from)


func debug_error(text:String, from:String="CHAT"):
	# Displays a DEBUG message
	# Only visible when UI>SETTINGS>DEBUG is true
	var kind = "ERROR"
	
	append_timestamp()
	
	append_debug_tag()
	
	append_tag(from, {
		"text_color": Color.whitesmoke,
		"tag_color": Color.white
	})
	
	append_text(text, {
		"text_color": Color.red
	})
	
	push_log("debug", text, kind, from)


func info(text:String, from:String="CHAT"):
	# This is going to be the default pattern for PEOPLE sending messages to the
	# chat. At least for now
	var kind = "INFO"
	
	append_timestamp()
	
	append_info_tag()
	
	append_from(from, {
		"name_color": Color.lightblue
	})
	
	
	append_text(text)
	
	
	push_log("messages", text, kind, from)


func success(text:String, from:String="CHAT"):
	# This is going to be the default pattern for PEOPLE sending messages to the
	# chat. At least for now
	var kind = "SUCCESS"
	
	append_timestamp()
	
	append_success_tag()
	
	append_from(from, {
		"text_color": Color.white
	})
	
	
	append_text(text, {
		"text_color": Color.green
	})
	
	
	push_log("messages", text, kind, from)


func error(text:String, from:String="CHAT"):
	# This is going to be the default pattern for PEOPLE sending messages to the
	# chat. At least for now
	var kind = "ERROR"
	
	append_timestamp()
	
	append_error_tag()
	
	append_from(from, {
		"text_color": Color.white
	})
	
	append_text(text, {
		"text_color": Color.red
	})
	
	push_log("messages", text, kind, from)


func say(text:String, from:String, chat:String):
	# This is going to be the default pattern for PEOPLE sending messages to the
	# chat. At least for now
	
	append_timestamp()
	
	append_chat_tag(chat)
	
	append_from(from, {
		"text_color" : Color.blue
	})
	
	
	append_text(text)
	
	
	push_log("messages", text, chat, from)

