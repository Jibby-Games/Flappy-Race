extends MenuControl


const MAX_CONNECT_TIME := 10
const MAIN_SERVER_URL := "jibby.games"

var title_scene := "res://client/menu/title/title_screen.tscn"
var server_browser_scene := "res://client/menu/lobby/server_browser.tscn"

onready var error_message = $VBoxContainer/Menu/ErrorMessage
onready var info_message = $VBoxContainer/Menu/InfoMessage
onready var ip_input = $VBoxContainer/Menu/CenterContainer/ButtonContainer/IpContainer/IpInput
onready var name_input = $VBoxContainer/Menu/CenterContainer/ButtonContainer/NameContainer/NameInput

var enable_upnp := true

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
	Globals.player_name = name_input.text
	Network.start_multiplayer_host(Network.RPC_PORT, enable_upnp)


func _on_JoinButton_pressed() -> void:
	if is_name_empty():
		return
	Globals.player_name = name_input.text
	show_info("Connecting...")
	var join_ip = ip_input.text
	if join_ip.is_valid_ip_address():
		error_message.hide()
		try_connect_to_server(join_ip)
	else:
		show_error("Invalid IP!")


func _on_JoinPublicButton_pressed() -> void:
	if is_name_empty():
		return
	Globals.player_name = name_input.text
	show_info("Connecting...")
	error_message.hide()
	try_connect_to_server(MAIN_SERVER_URL)


func _on_BackButton_pressed() -> void:
	change_menu(title_scene)


func is_name_empty() -> bool:
	if name_input.text.empty():
		show_error("Please enter a name")
		return true
	error_message.hide()
	return false


func try_connect_to_server(ip: String) -> void:
	$ConnectionTimer.start(MAX_CONNECT_TIME)
	Network.Client.start_client(ip, Network.RPC_PORT)


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
