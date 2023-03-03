extends Node

signal connection_established
signal connection_closed
signal connection_error

export var server_list_url := "http://jibby.games"
export var server_list_route := "api/servers/ws"

# Our WebSocketClient instance
var _client := WebSocketClient.new()
var server_name := ""
var connection_started := false


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
	result = $ReconnectionTimer.connect("timeout", self, "_try_connect")

func _closed(was_clean = false):
	# was_clean will tell you if the disconnection was correctly notified
	# by the remote peer before closing the socket.
	Logger.print(self, "Server list connection closed - attempting to reconnect, clean: %s" % was_clean)
	$ReconnectionTimer.start()
	emit_signal("connection_closed")


func _error() -> void:
	Logger.print(self, "Server list connection error - attempting to reconnect")
	$ReconnectionTimer.start()
	emit_signal("connection_error")


func _connected(protocol = ""):
	Logger.print(self, "Server list connected with protocol: %s" % protocol)
	# The server list expects the name to be sent first
	_send_json({ "name": server_name, "port": Network.Server.port })
	$ReconnectionTimer.stop()
	emit_signal("connection_established")


func _on_data():
	# Print the received packet, you MUST always use get_peer(1).get_packet
	# to receive data from server
	Logger.print(self, "Received data from server list: %s" % [_client.get_peer(1).get_packet().get_string_from_utf8()])


func _process(_delta):
	# Data transfer, and signals emission will only happen when calling this function.
	_client.poll()


func start_connection(_server_name: String) -> void:
	if _server_name.empty():
		push_error("Server name cannot be empty when connecting to the server list!")
		return
	if connection_started:
		push_error("Server list connection already started!")
		return
	Logger.print(self, "Started connection to server list (url: %s, server_name: %s)" % [server_list_url, _server_name])
	self.server_name = _server_name
	connection_started = true
	_try_connect()


func _try_connect() -> void:
	if is_connected_to_server_list():
		push_error("Already connected to the server list!")
		return
	if self.server_name.empty():
		push_error("Server name cannot be empty when connecting to the server list!")
		return
	var url = "%s/%s" % [server_list_url, server_list_route]
	Logger.print(self, "Attempting connection to %s..." % url)
	var result = _client.connect_to_url(url, ["json"], false, ["User-Agent: Flappy-Race-Server"])
	if result != OK:
		Logger.print(self, "Unable to connect to server list - will try again")
		$ReconnectionTimer.start()
		return
	_client.get_peer(1).set_write_mode(WebSocketPeer.WRITE_MODE_TEXT)
	$ReconnectionTimer.stop()


func stop_connection() -> void:
	if not connection_started:
		push_error("Server list connection already stopped!")
		return
	$ReconnectionTimer.stop()
	if is_connected_to_server_list():
		_client.get_peer(1).close()
	connection_started = false
	Logger.print(self, "Stopped connection to server list")


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
