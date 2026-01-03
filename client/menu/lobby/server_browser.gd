extends MenuControl

export(String) var server_list_route = "servers"
export(PackedScene) var server_entry

var name_entry := "res://client/menu/lobby/name_entry.tscn"
var host_setup := "res://client/menu/lobby/host_setup.tscn"
var self_host_setup := "res://client/menu/lobby/self_host_setup.tscn"

onready var server_list_entries = $Panel/ServerListContainer/ServerListEntries
onready var error_message = $Panel/CenterContainer/ErrorMessage
onready var info_message = $Panel/CenterContainer/InfoMessage


func _ready() -> void:
	var result: int
	result = multiplayer.connect("connected_to_server", self, "_on_connected")
	assert(result == OK)
	result = multiplayer.connect("connection_failed", self, "_on_connection_failed")
	assert(result == OK)
	get_server_list()
	if OS.has_feature('web'):
		$Panel/CenterContainer2/ButtonContainer/SelfHostButton.hide()


func _on_connected() -> void:
	Network.Client.change_scene_to_setup()


func _on_connection_failed() -> void:
	Logger.print(self, "Connection failed!")


func _on_RefreshButton_pressed() -> void:
	get_server_list()


func get_server_list() -> void:
	info_message.hide()
	error_message.hide()
	clear_servers()
	$ServerRequest.cancel_request()
	var url = "%s/%s" % [Network.SERVER_LIST_URL, server_list_route]
	Logger.print(self, "Trying to get server list from %s...", [url])
	var result: int = $ServerRequest.request(url)
	assert(result == OK)
	show_info("Connecting...")


func _on_ServerRequest_request_completed(
	result: int, response_code: int, _headers: PoolStringArray, body: PoolByteArray
) -> void:
	info_message.hide()
	match result:
		HTTPRequest.RESULT_SUCCESS:
			pass
		_:
			show_error("Connection Error: %s" % [Network.get_http_result_name(result)])
			return
	match response_code:
		HTTPClient.RESPONSE_OK:
			pass
		_:
			show_error("Error: HTTP response code %d" % [response_code])
			return
	var body_str = body.get_string_from_utf8()
	var servers = parse_json(body_str)
	if not servers is Array:
		show_error("Server returned unexpected data")
		return
	populate_servers(servers as Array)


func show_info(msg: String) -> void:
	error_message.hide()
	Logger.print(self, msg)
	info_message.text = msg
	info_message.show()


func show_error(msg: String) -> void:
	info_message.hide()
	Logger.print(self, msg)
	error_message.text = msg
	error_message.show()


func clear_servers() -> void:
	for server in server_list_entries.get_children():
		server_list_entries.remove_child(server)
		server.queue_free()


func populate_servers(servers: Array) -> void:
	if servers.empty():
		show_info("No servers found!")
		return
	var any_servers = false
	for server in servers:
		if OS.has_feature('web') and server.get("tls", false) == false:
			# HTML5 builds can only connect to tls enabled servers, so don't show them
			continue
		any_servers = true
		var entry = server_entry.instance()
		entry.setup(server)
		server_list_entries.add_child(entry)
	if not any_servers:
		show_info("No compatible servers found!")


func _on_BackButton_pressed() -> void:
	change_menu(name_entry)


func _on_RefreshTimer_timeout() -> void:
	get_server_list()


func _on_CreateButton_pressed() -> void:
	change_menu(host_setup)


func _on_SelfHostButton_pressed() -> void:
	change_menu(self_host_setup)


func _on_IpJoinButton_pressed() -> void:
	$JoinPanel.popup_centered()
