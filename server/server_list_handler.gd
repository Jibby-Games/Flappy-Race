extends Node

signal connection_established
signal connection_closed
signal connection_error

# The URL we will connect to
export var server_list_url := "ws://127.0.0.1:3000/api/servers/ws"

# Our WebSocketClient instance
var _client := WebSocketClient.new()
var server_name := ""


func _ready():
	# Connect base signals to get notified of connection events
	var result := _client.connect("connection_closed", self, "_closed")
	assert(result == OK)
	result = _client.connect("connection_error", self, "_closed")
	assert(result == OK)
	result = _client.connect("connection_established", self, "_connected")
	assert(result == OK)
	result = _client.connect("data_received", self, "_on_data")
	assert(result == OK)

func _closed(was_clean = false):
	# was_clean will tell you if the disconnection was correctly notified
	# by the remote peer before closing the socket.
	print_debug("Server list connection closed, clean: ", was_clean)
	emit_signal("connection_closed")


func _error() -> void:
	print_debug("Server list connection error")
	emit_signal("connection_error")


func _connected(protocol = ""):
	print_debug("Server list connected with protocol: ", protocol)
	# The server list expects the name to be sent first
	_send_json({ "name": server_name })
	emit_signal("connection_established")


func _on_data():
	# Print the received packet, you MUST always use get_peer(1).get_packet
	# to receive data from server
	print_debug("Received data from server list: ", _client.get_peer(1).get_packet().get_string_from_utf8())


func _process(_delta):
	# Data transfer, and signals emission will only happen when calling this function.
	_client.poll()


func start_connection(_server_name: String) -> void:
	if is_connected_to_server_list():
		push_error("Already connected to the server list!")
		return
	if _server_name.empty():
		push_error("Server name cannot be empty when connecting to the server list!")
		return
	self.server_name = _server_name
	var result = _client.connect_to_url(server_list_url, ["json"], false, ["User-Agent: Flappy-Race-Server"])
	if result != OK:
		print_debug("Unable to connect to server list")
		return
	_client.get_peer(1).set_write_mode(WebSocketPeer.WRITE_MODE_TEXT)


func stop_connection() -> void:
	if not is_connected_to_server_list():
		push_error("Server list connection already stopped!")
		return
	_client.get_peer(1).close()


func is_connected_to_server_list() -> bool:
	return _client.get_peer(1).is_connected_to_host()


func send_players(value: int) -> void:
	_send_json({ "players": value })


func _send_json(dict: Dictionary) -> void:
	if not is_connected_to_server_list():
		push_error("Must be connected to the server list to send data!")
		return
	# Must always use get_peer(1).put_packet to send data to server
	var result := _client.get_peer(1).put_packet(to_json(dict).to_utf8())
	assert(result == OK)
