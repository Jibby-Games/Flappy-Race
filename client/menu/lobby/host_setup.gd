extends MenuControl

const MAX_CONNECT_TIME := 10

var server_browser_scene := "res://client/menu/lobby/server_browser.tscn"

var game_manager_route = "api/request"

onready var error_message = $VBoxContainer/Menu/ErrorMessage
onready var info_message = $VBoxContainer/Menu/InfoMessage
onready var server_name_input = $VBoxContainer/Menu/CenterContainer/ButtonContainer/ServerNameContainer/ServerNameInput

func _ready() -> void:
	var result: int
	result = multiplayer.connect("connected_to_server", self, "_on_connected")
	assert(result == OK)
	result = multiplayer.connect("connection_failed", self, "_on_connection_failed")
	assert(result == OK)
	server_name_input.text = "%s's Game" % Globals.player_name


func _on_BackButton_pressed() -> void:
	change_menu(server_browser_scene)


func _on_connected() -> void:
	$ConnectionTimer.stop()
	Network.Client.change_scene_to_setup()


func _on_connection_failed() -> void:
	show_error("Failed to connect to official server!")


func _on_ConnectionTimer_timeout() -> void:
	Network.Client.stop_client()
	show_error("Failed to connect to official server!")


func show_info(message: String) -> void:
	error_message.hide()
	info_message.text = message
	info_message.show()


func show_error(message: String) -> void:
	info_message.hide()
	error_message.text = message
	error_message.show()


func _on_CreateButton_pressed() -> void:
	if server_name_input.text.empty():
		show_error("Please enter a server name")
		return
	error_message.hide()
	show_info("Creating server...")
	var http = HTTPRequest.new()
	http.connect("request_completed", self, "_on_HTTPCreate_request_completed")
	add_child(http)
	var url = "%s/%s" % [Network.SERVER_LIST_URL, game_manager_route]
	# Convert data to json string:
	var data = {"name": server_name_input.text}
	# Add 'Content-Type' header:
	var headers = ["Content-Type: application/json"]
	http.request(url, headers, true, HTTPClient.METHOD_POST, to_json(data))


func _on_HTTPCreate_request_completed(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray) -> void:
	if result == HTTPRequest.RESULT_SUCCESS and response_code == 201:
		# Successful response
		var resp = parse_json(body.get_string_from_utf8())
		if typeof(resp) != TYPE_DICTIONARY:
			push_error("Received invalid object type, expected Dictionary, got: %s" % typeof(resp))
			return
		if not resp.has("port"):
			push_error("Couldn't find a port in the response: %s" % resp)
			return
		if not typeof(resp.port) == TYPE_REAL:
			push_error("Port must be a numerical type (float), got: %s" % typeof(resp.port))
			return
		try_connect_to_server(Network.SERVER_LIST_URL, int(resp.port))
	else:
		Logger.print(self,
"""Unable to create new game! HTTP request returned:
result = %d
response_code = %d
headers = %s
body = %s
""" % [result, response_code, headers, body.get_string_from_utf8()])

func try_connect_to_server(ip: String, port: int) -> void:
	show_info("Server created, connecting...")
	$ConnectionTimer.start(MAX_CONNECT_TIME)
	Network.Client.start_client(ip, port)
