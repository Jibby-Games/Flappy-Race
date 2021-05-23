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


func change_scene_to(scene: PackedScene) -> void:
	print("[CNT] Changing scene to %s" % scene.get_path())
	.change_scene_to(scene)


func _ready() -> void:
	# As you can see, instead of calling get_tree().connect for network related
	# stuff we use mutltiplayer.connect . This way, IF (and only IF) the
	# MultiplayerAPI is customized, we use that instead of the global one.
	# This makes the custom MultiplayerAPI almost plug-n-play.
	assert(multiplayer.connect("connection_failed", self, "_on_connection_failed") == OK)
	assert(multiplayer.connect("connected_to_server", self, "_on_connected_to_server") == OK)
	assert(multiplayer.connect("server_disconnected", self, "_on_server_disconnected") == OK)


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
	print("[CNT]: Client started")


func stop_client() -> void:
	multiplayer.set_network_peer(null)
	print("[CNT]: Client stopped")


func _on_connection_failed() -> void:
	print("[CNT]: Failed to connect to server!")
	stop_client()


func _on_connected_to_server() -> void:
	print("[CNT]: Successfully connected to server!")
	rpc_id(SERVER_ID, "fetch_server_time", OS.get_system_time_msecs())
	var timer = Timer.new()
	timer.autostart = true
	timer.connect("timeout", self, "determine_latency")
	self.add_child(timer)


func _on_server_disconnected() -> void:
	print("[CNT]: Disconnected from server!")
	stop_client()


remote func return_server_time(server_time, client_time) -> void:
	latency = (OS.get_system_time_msecs() - client_time) / 2
	client_clock = server_time + latency


func determine_latency() -> void:
	rpc_id(SERVER_ID, "determine_latency", OS.get_system_time_msecs())


remote func return_latency(client_time) -> void:
	latency_array.append((OS.get_system_time_msecs() - client_time) / 2)
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


remote func populate_player_list(players: PoolIntArray) -> void:
	var sender = multiplayer.get_rpc_sender_id()
	if sender == SERVER_ID:
		$GameSetup.populate_players(players)
	else:
		print("[CNT]: ERROR Received player list from player %s, is someone hacking?" % sender)


remote func despawn_player(player_id: int) -> void:
	$World.despawn_player(player_id)


func request_start_game() -> void:
	print("[CNT]: Sending start game request")
	rpc_id(SERVER_ID, "request_start_game")


remote func game_started(game_seed) -> void:
	var sender = multiplayer.get_rpc_sender_id()
	if sender == SERVER_ID:
		change_scene("res://client/world/world.tscn")
		_active_scene.start_game(game_seed)


func send_player_state(player_state: Dictionary) -> void:
	rpc_unreliable_id(SERVER_ID, "receive_player_state", player_state)


remote func receive_world_state(world_state: Dictionary) -> void:
	_active_scene.update_world_state(world_state)
