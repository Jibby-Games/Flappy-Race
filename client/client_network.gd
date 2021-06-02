extends SceneHandler


class_name ClientNetwork


const SERVER_ID := 1
const LATENCY_BUFFER_SIZE := 9
const LATENCY_THRESHOLD := 20


var client_clock: int = 0
var latency = 0
var delta_latency = 0
var decimal_collector: float = 0
var latency_array = []


func _ready() -> void:
	# As you can see, instead of calling get_tree().connect for network related
	# stuff we use mutltiplayer.connect . This way, IF (and only IF) the
	# MultiplayerAPI is customized, we use that instead of the global one.
	# This makes the custom MultiplayerAPI almost plug-n-play.
	assert(multiplayer.connect("connection_failed", self, "_on_connection_failed") == OK)
	assert(multiplayer.connect("connected_to_server", self, "_on_connected_to_server") == OK)
	assert(multiplayer.connect("server_disconnected", self, "_on_server_disconnected") == OK)

	# Register with the Network singleton so this node can be easily accessed
	Network.Client = self

	# The client should always start at the title screen
	change_scene("res://client/menu/title/title_screen.tscn")


func _physics_process(delta: float):
	client_clock += int(delta * 1000) + delta_latency
	delta_latency = 0
	decimal_collector += (delta * 1000) - int(delta * 1000)
	if decimal_collector >= 1.00:
		client_clock += 1
		decimal_collector -= 1.00


func _exit_tree() -> void:
	multiplayer.disconnect("connection_failed", self, "_on_connection_failed")
	multiplayer.disconnect("connected_to_server", self, "_on_connected_to_server")
	multiplayer.disconnect("server_disconnected", self, "_on_server_disconnected")


func start_client(host, port) -> void:
	var peer = NetworkedMultiplayerENet.new()
	peer.create_client(host, port)
	multiplayer.set_network_peer(peer)
	print("[%s] Client started" % [get_path().get_name(1)])


func stop_client() -> void:
	$LatencyUpdater.stop()
	multiplayer.set_network_peer(null)
	print("[%s] Client stopped" % [get_path().get_name(1)])


func _on_connection_failed() -> void:
	print("[%s] Failed to connect to server!" % [get_path().get_name(1)])
	stop_client()


func _on_connected_to_server() -> void:
	print("[%s] Successfully connected to server!" % [get_path().get_name(1)])
	send_clock_sync_request()
	$LatencyUpdater.start()


func _on_server_disconnected() -> void:
	print("[%s] Disconnected from server!" % [get_path().get_name(1)])
	stop_client()


func is_rpc_from_server() -> bool:
	var sender: int = multiplayer.get_rpc_sender_id()
	if sender != SERVER_ID:
		push_error("Received RPC from player %d - they may be hacking!" % sender)
		return false
	return true


func send_clock_sync_request() -> void:
	rpc_id(SERVER_ID, "receive_clock_sync_request", OS.get_system_time_msecs())


remote func receive_clock_sync_response(server_time: int, client_time: int) -> void:
	if is_rpc_from_server() == false:
		return
	latency = (OS.get_system_time_msecs() - client_time) / 2.0
	client_clock = server_time + latency


func send_latency_request() -> void:
	rpc_id(SERVER_ID, "receive_latency_request", OS.get_system_time_msecs())


remote func receive_latency_response(client_time: int) -> void:
	if is_rpc_from_server() == false:
		return
	latency_array.append((OS.get_system_time_msecs() - client_time) / 2.0)
	if latency_array.size() == LATENCY_BUFFER_SIZE:
		var total_latency = 0
		latency_array.sort()
		# warning-ignore: integer_division
		var mid_point = latency_array[LATENCY_BUFFER_SIZE / 2]
		for i in range(latency_array.size() - 1, -1, -1):
			# This removes any extreme values from the latency calculation
			# The latency threshold is needed for super-fast connections since
			# they will have very small values and we don't want to discard
			# everything
			if latency_array[i] > (2 * mid_point) and latency_array[i] > LATENCY_THRESHOLD:
				latency_array.remove(i)
			else:
				total_latency += latency_array[i]
		var average_latency = total_latency / latency_array.size()
		delta_latency = average_latency - latency
		latency = average_latency
		latency_array.clear()


remote func receive_player_list_update(players: PoolIntArray) -> void:
	if is_rpc_from_server() == false:
		return
	var setup = get_node_or_null("GameSetup")
	if setup:
		setup.populate_players(players)


func send_client_ready() -> void:
	rpc_id(SERVER_ID, "receive_client_ready")


remote func receive_despawn_player(player_id: int) -> void:
	if is_rpc_from_server() == false:
		return
	var world = get_node_or_null("World")
	if world:
		world.despawn_player(player_id)


func send_start_game_request() -> void:
	print("[%s] Sending start game request" % [get_path().get_name(1)])
	rpc_id(SERVER_ID, "receive_start_game_request")


remote func receive_load_world() -> void:
	if is_rpc_from_server() == false:
		return
	change_scene("res://client/world/world.tscn")


remote func receive_game_started(game_seed: int) -> void:
	if is_rpc_from_server() == false:
		return
	var world = get_node_or_null("World")
	if world:
		world.start_game(game_seed)


func send_player_state(player_state: Dictionary) -> void:
	rpc_unreliable_id(SERVER_ID, "receive_player_state", player_state)


remote func receive_world_state(world_state: Dictionary) -> void:
	if is_rpc_from_server() == false:
		return
	var world = get_node_or_null("World")
	if world:
		world.update_world_state(world_state)
