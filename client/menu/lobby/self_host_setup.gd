extends MenuControl

var server_browser_scene := "res://client/menu/lobby/server_browser.tscn"

var use_upnp := true
var use_server_list := true

onready var error_message = $VBoxContainer/Menu/ErrorMessage
onready var info_message = $VBoxContainer/Menu/InfoMessage
onready var server_name_input = $VBoxContainer/Menu/CenterContainer/ButtonContainer/ServerNameContainer/ServerNameInput
onready var port_input = $VBoxContainer/Menu/CenterContainer/ButtonContainer/HostOptionsContainer/PortInput

func _ready() -> void:
	var result: int
	result = multiplayer.connect("connected_to_server", self, "_on_connected")
	assert(result == OK)
	result = multiplayer.connect("connection_failed", self, "_on_connection_failed")
	assert(result == OK)
	server_name_input.text = "%s's Game" % Globals.player_name
	port_input.text = str(Network.RPC_PORT)


func _on_HostButton_pressed() -> void:
	var port := 0
	if server_name_input.text.empty():
		show_error("Please enter a server name")
		return
	if port_input.text.empty() or not port_input.text.is_valid_integer():
		show_error("Please enter a valid port")
		return
	port = int(port_input.text)
	if port < 1 or port > 65535:
		show_error("Port must be between 1 and 65535")
		return
	error_message.hide()
	Network.start_multiplayer_host(int(port_input.text), use_upnp, server_name_input.text, use_server_list)


func _on_BackButton_pressed() -> void:
	change_menu(server_browser_scene)


func _on_connected() -> void:
	Network.Client.change_scene_to_setup()


func _on_connection_failed() -> void:
	show_error("Failed to connect to self hosted server!")


func show_info(message: String) -> void:
	error_message.hide()
	info_message.text = message
	info_message.show()


func show_error(message: String) -> void:
	info_message.hide()
	error_message.text = message
	error_message.show()


func _on_UpnpToggle_toggled(button_pressed: bool) -> void:
	use_upnp = button_pressed


func _on_ServerListToggle_toggled(button_pressed: bool) -> void:
	use_server_list = button_pressed
