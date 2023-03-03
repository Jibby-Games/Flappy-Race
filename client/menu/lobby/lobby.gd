extends MenuControl


const MAX_CONNECT_TIME := 10

var title_scene := "res://client/menu/title/title_screen.tscn"
var server_browser_scene := "res://client/menu/lobby/server_browser.tscn"

onready var error_message = $VBoxContainer/Menu/ErrorMessage
onready var info_message = $VBoxContainer/Menu/InfoMessage
onready var ip_input = $VBoxContainer/Menu/CenterContainer/ButtonContainer/IpContainer/IpInput
onready var name_input = $VBoxContainer/Menu/CenterContainer/ButtonContainer/NameContainer/NameInput
onready var server_name_input = $VBoxContainer/Menu/CenterContainer/ButtonContainer/HostOptions/ServerNameInput

var enable_upnp := true
var game_manager_route = "api/request"

func _ready() -> void:
	var result: int
	result = multiplayer.connect("connected_to_server", self, "_on_connected")
	assert(result == OK)
	result = multiplayer.connect("connection_failed", self, "_on_connection_failed")
	assert(result == OK)
	name_input.text = Globals.player_name


func _on_HostButton_pressed() -> void:
	if is_name_empty():
		return
	if is_server_name_empty():
		return
	Globals.player_name = name_input.text
	Network.start_multiplayer_host(Network.RPC_PORT, enable_upnp, server_name_input.text)


func _on_JoinButton_pressed() -> void:
	if is_name_empty():
		return
	Globals.player_name = name_input.text
	show_info("Connecting...")
	var join_ip: String = ip_input.text
	var port := Network.RPC_PORT
	if ":" in join_ip:
		var parts = join_ip.split(":")
		join_ip = parts[0]
		port = int(parts[1])
	if join_ip.is_valid_ip_address():
		error_message.hide()
		try_connect_to_server(join_ip, port)
	else:
		show_error("Invalid IP!")


func _on_BackButton_pressed() -> void:
	change_menu(title_scene)


func is_name_empty() -> bool:
	if name_input.text.empty():
		show_error("Please enter a name")
		return true
	error_message.hide()
	return false


func is_server_name_empty() -> bool:
	if server_name_input.text.empty():
		show_error("Please enter a server name")
		return true
	error_message.hide()
	return false


func try_connect_to_server(ip: String, port: int) -> void:
	$ConnectionTimer.start(MAX_CONNECT_TIME)
	Network.Client.start_client(ip, port)


func _on_connected() -> void:
	$ConnectionTimer.stop()
	Network.Client.change_scene_to_setup()


func _on_connection_failed() -> void:
	Logger.print(self, "Connection failed!")
	show_error("Failed to connect!")


func _on_ConnectionTimer_timeout() -> void:
	Logger.print(self, "Connection timed out!")
	Network.Client.stop_client()
	show_error("Failed to connect!")


func show_info(message: String) -> void:
	error_message.hide()
	info_message.text = message
	info_message.show()


func show_error(message: String) -> void:
	info_message.hide()
	error_message.text = message
	error_message.show()


func _on_UpnpToggle_toggled(button_pressed: bool) -> void:
	enable_upnp = button_pressed


func _on_ServerBrowserButton_pressed() -> void:
	change_menu(server_browser_scene)


func _on_CreateButton_pressed() -> void:
	var http = HTTPRequest.new()
	http.connect("request_completed", self, "_on_HTTPCreate_request_completed")
	add_child(http)
	var url = "%s/%s" % [Network.SERVER_LIST_URL, game_manager_route]
	http.request(url)


func _on_HTTPCreate_request_completed(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray) -> void:
	if result == HTTPRequest.RESULT_SUCCESS and response_code == 200:
		# Successful response
		var game_port := body.get_string_from_utf8()
		if game_port.is_valid_integer():
			try_connect_to_server(Network.SERVER_LIST_URL, int(game_port))
		else:
			push_error("Received invalid game port from server: %s" % game_port)
	else:
		Logger.print(self,
"""Unable to create new game! HTTP request returned:
result = %d
response_code = %d
headers = %s
body = %s
""" % [result, response_code, headers, body.get_string_from_utf8()])
