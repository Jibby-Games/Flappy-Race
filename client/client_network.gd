extends SceneHandler


class_name ClientNetwork


const SERVER_ID := 1
const LATENCY_BUFFER_SIZE := 9
const LATENCY_THRESHOLD := 20


# Clock sync and latency vars
var client_clock: int = 0
var latency = 0
var delta_latency = 0
var decimal_collector: float = 0
var latency_array = []


var is_singleplayer := false
var host_player_id := 0


signal host_changed(new_host_id)


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


func _physics_process(delta: float) -> void:
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


func start_client(host: String, port: int, singleplayer: bool = false) -> void:
	is_singleplayer = singleplayer
	var peer = NetworkedMultiplayerENet.new()
	peer.create_client(host, port)
	multiplayer.set_network_peer(peer)
	Logger.print(self, "Client started")


func stop_client() -> void:
	$LatencyUpdater.stop()
	multiplayer.network_peer.close_connection()
	multiplayer.set_network_peer(null)
	Logger.print(self, "Client stopped")


func _on_connection_failed() -> void:
	Logger.print(self, "Failed to connect to server!")
	stop_client()


func _on_connected_to_server() -> void:
	Logger.print(self, "Successfully connected to server!")
	send_clock_sync_request()
	$LatencyUpdater.start()
	Network.Client.send_player_settings(Globals.player_name, Globals.player_colour)


func _on_server_disconnected() -> void:
	Logger.print(self, "Disconnected from server!")
	stop_client()
	Network.Client.change_scene("res://client/menu/title/title_screen.tscn")
	Globals.show_message("Lost connection to the server.", "Server Disconnect")


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


remote func receive_host_change(new_host_id: int) -> void:
	if is_rpc_from_server() == false:
		return
	host_player_id = new_host_id
	emit_signal("host_changed", new_host_id)
	Logger.print(self, "Host player changed to player %d", [new_host_id])


func is_host() -> bool:
	return host_player_id == multiplayer.get_network_unique_id()


func is_host_id(player_id: int) -> bool:
	return host_player_id == player_id


func send_player_settings(player_name: String, player_colour: int) -> void:
	rpc_id(SERVER_ID, "receive_player_settings", player_name, player_colour)


remote func receive_player_list_update(player_list: Dictionary) -> void:
	if is_rpc_from_server() == false:
		return
	var setup = get_node_or_null("MultiplayerSetup")
	if setup:
		setup.populate_players(player_list)


func send_player_colour_change(colour_choice: int) -> void:
	rpc_id(SERVER_ID, "receive_player_colour_change", colour_choice)


remote func receive_player_colour_update(player_id: int, colour_choice: int) -> void:
	if is_rpc_from_server() == false:
		return
	var setup = get_node_or_null("MultiplayerSetup")
	if setup:
		setup.update_player_colour(player_id, colour_choice)


func send_player_spectate_change(is_spectating: bool) -> void:
	rpc_id(SERVER_ID, "receive_player_spectate_change", is_spectating)


remote func receive_player_spectate_update(player_id: int, is_spectating: bool) -> void:
	if is_rpc_from_server() == false:
		return
	var setup = get_node_or_null("MultiplayerSetup")
	if setup:
		setup.update_player_spectating(player_id, is_spectating)


func send_goal_change(goal: int) -> void:
	if is_host():
		rpc_id(SERVER_ID, "receive_goal_change", goal)


remote func receive_goal_change(goal: int) -> void:
	if is_rpc_from_server() == false:
		return
	var options = get_node_or_null("MultiplayerSetup/Setup/GameOptions")
	if options:
		options.set_goal(goal)


func send_client_ready() -> void:
	rpc_id(SERVER_ID, "receive_client_ready")


func send_player_death() -> void:
	rpc_id(SERVER_ID, "receive_player_death")


remote func receive_despawn_player(player_id: int) -> void:
	if is_rpc_from_server() == false:
		return
	var world = get_node_or_null("World")
	if world:
		world.despawn_player(player_id)


func send_start_game_request() -> void:
	Logger.print(self, "Sending start game request")
	rpc_id(SERVER_ID, "receive_start_game_request")


remote func receive_load_world() -> void:
	if is_rpc_from_server() == false:
		return
	change_scene("res://client/world/world.tscn")


remote func receive_game_started(game_seed: int, goal: int, player_list: Dictionary) -> void:
	if is_rpc_from_server() == false:
		return
	var world = get_node_or_null("World")
	if world:
		world.start_game(game_seed, goal, player_list)


func send_player_state(player_state: Dictionary) -> void:
	rpc_unreliable_id(SERVER_ID, "receive_player_state", player_state)


remote func receive_world_state(world_state: Dictionary) -> void:
	if is_rpc_from_server() == false:
		return
	var world = get_node_or_null("World")
	if world:
		world.update_world_state(world_state)


remote func receive_player_finished_race(player_id: int, place: int) -> void:
	if is_rpc_from_server() == false:
		return
	var world = get_node_or_null("World")
	if world:
		world.player_finished(player_id, place)


remote func receive_leaderboard(leaderboard: Array) -> void:
	if is_rpc_from_server() == false:
		return
	var ui = get_node_or_null("World/UI")
	if ui:
		ui.show_leaderboard(leaderboard)
