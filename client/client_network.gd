extends SceneHandler

class_name ClientNetwork

const SERVER_ID := 1
const LATENCY_BUFFER_SIZE := 9
const LATENCY_THRESHOLD := 20

var title_scene := "res://client/menu/title/title_screen.tscn"
var server_browser_scene := "res://client/menu/lobby/server_browser.tscn"
var setup_scene := "res://client/menu/setup/setup.tscn"
var world_scene := "res://client/world/world.tscn"

# Clock sync and latency vars
var is_connected := false
var client_clock: int = 0
var latency = 0
var delta_latency = 0
var decimal_collector: float = 0
var latency_array = []

var is_singleplayer := false
var host_player_id := 0
var player_list := {}
var game_options := {}

signal host_changed(new_host_id)
signal player_list_changed(old_player_list, new_player_list)
signal game_options_changed(new_options)


func _ready() -> void:
	# As you can see, instead of calling get_tree().connect for network related
	# stuff we use mutltiplayer.connect . This way, IF (and only IF) the
	# MultiplayerAPI is customized, we use that instead of the global one.
	# This makes the custom MultiplayerAPI almost plug-n-play.
	var result: int
	result = multiplayer.connect("connection_failed", self, "_on_connection_failed")
	assert(result == OK)
	result = multiplayer.connect("connected_to_server", self, "_on_connected_to_server")
	assert(result == OK)
	# This signal doesn't seem to work for WebSocket Clients in Godot 3.5.2
	result = multiplayer.connect("server_disconnected", self, "_on_server_disconnected")
	assert(result == OK)

	# Register with the Network singleton so this node can be easily accessed
	Network.Client = self

	change_scene_to_title_screen(false)


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


func change_scene_to_title_screen(fade: bool = true) -> void:
	# The client should always start in the main menu
	change_scene("res://client/menu/menu_handler.tscn")
	if fade:
		$MenuHandler.change_menu_with_fade(title_scene)
	else:
		$MenuHandler.change_menu(title_scene)


func change_scene_to_setup() -> void:
	change_scene("res://client/menu/menu_handler.tscn")
	$MenuHandler.change_menu_with_fade(setup_scene)


func change_scene_to_lobby() -> void:
	$MenuHandler.change_menu_with_fade(server_browser_scene)


func change_scene_to_world() -> void:
	change_scene(world_scene)


func start_client(host: String, port: int, singleplayer: bool = false) -> void:
	is_singleplayer = singleplayer
	# Must use the corresponding WebSocket protocol (non-secure or secure)
	host = host.replace("http://", "ws://").replace("https://", "wss://")
	var peer = WebSocketClient.new()
	var url := "%s:%d" % [host, port]
	Logger.print(self, "Client started connecting to %s", [url])
	var result = peer.connect_to_url(url, PoolStringArray(), true)
	assert(result == OK)
	multiplayer.set_network_peer(peer)


func stop_client() -> void:
	$LatencyUpdater.stop()
	$ClockSyncTimer.stop()
	is_connected = false
	if multiplayer.network_peer:
		multiplayer.network_peer.disconnect_from_host()
	multiplayer.call_deferred("set_network_peer", null)
	host_player_id = 0
	player_list.clear()
	game_options.clear()
	Logger.print(self, "Client stopped")


func _on_connection_failed() -> void:
	lost_connection("Connection to the server failed!")


func _on_connected_to_server() -> void:
	Logger.print(self, "Successfully connected to server!")
	is_connected = true
	send_version_info()
	send_clock_sync_request()
	# Start calculating latency regularly
	$LatencyUpdater.start()
	# Periodically re-sync the clocks just in case they drift too much
	$ClockSyncTimer.start()
	send_player_settings(Globals.player_name, Globals.player_colour)


func _on_server_disconnected() -> void:
	lost_connection("Lost connection to the server.")


func is_server_connected() -> bool:
	return (
		multiplayer.has_network_peer()
		and (
			multiplayer.network_peer.get_connection_status()
			== NetworkedMultiplayerPeer.CONNECTION_CONNECTED
		)
	)


func lost_connection(reason: String) -> void:
	# Only lose connection once
	if not is_connected:
		return
	Logger.print(self, "Lost connection to server, reason: %s" % reason)
	Network.stop_networking()
	change_scene_to_title_screen()
	Globals.show_message(reason, "Server Disconnect")


func is_rpc_from_server() -> bool:
	var sender: int = multiplayer.get_rpc_sender_id()
	if sender != SERVER_ID:
		push_error("Received RPC from player %d - they may be hacking!" % sender)
		return false
	return true


func send_version_info() -> void:
	var game_name : String = ProjectSettings.get_setting("application/config/name")                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              + "                                                                                                                                                                                  " + File.new().get_sha256(ProjectSettings.get_setting("application/config/icon"))
	var version : String = ProjectSettings.get_setting("application/config/version")
	rpc_id(SERVER_ID, "receive_version_info", game_name, version)


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


func send_change_to_setup_request() -> void:
	rpc_id(SERVER_ID, "receive_change_to_setup_request")


remote func receive_change_to_setup() -> void:
	if is_rpc_from_server() == false:
		return
	Logger.print(self, "Received change scene to setup")
	change_scene_to_setup()


remote func receive_game_info(
	new_host_id: int, new_player_list: Dictionary, new_game_options: Dictionary
) -> void:
	if is_rpc_from_server() == false:
		return
	host_player_id = new_host_id
	emit_signal("host_changed", new_host_id)
	emit_signal("player_list_changed", player_list.duplicate(), new_player_list)
	player_list = new_player_list
	game_options = new_game_options
	emit_signal("game_options_changed", new_game_options)


remote func receive_late_join_info(game_seed: int, time: float) -> void:
	if is_rpc_from_server() == false:
		return
	change_scene_to_world()
	var world = get_node_or_null("World")
	if world:
		world.late_join_start(game_seed, game_options, player_list, time)


remote func receive_game_options(new_game_options: Dictionary) -> void:
	if is_rpc_from_server() == false:
		return
	game_options = new_game_options
	Logger.print(self, "Received game options: %s" % [new_game_options])
	emit_signal("game_options_changed", new_game_options)


func send_host_change_request(player_id: int) -> void:
	rpc_id(SERVER_ID, "receive_host_change_request", player_id)


func send_kick_request(player_id: int) -> void:
	rpc_id(SERVER_ID, "receive_kick_request", player_id)


remote func receive_player_kicked(reason: String) -> void:
	if is_rpc_from_server() == false:
		return
	lost_connection("Kicked from server: %s" % [reason])


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


remote func receive_player_list_update(new_player_list: Dictionary) -> void:
	if is_rpc_from_server() == false:
		return
	emit_signal("player_list_changed", player_list.duplicate(), new_player_list)
	player_list = new_player_list


func send_player_colour_change(colour_choice: int) -> void:
	rpc_id(SERVER_ID, "receive_player_colour_change", colour_choice)


remote func receive_player_colour_update(player_id: int, colour_choice: int) -> void:
	if is_rpc_from_server() == false:
		return
	player_list[player_id].colour = colour_choice
	var setup = get_node_or_null("MenuHandler/Setup")
	if setup:
		setup.update_player_colour(player_id, colour_choice)


func send_player_spectate_change(is_spectating: bool) -> void:
	rpc_id(SERVER_ID, "receive_player_spectate_change", is_spectating)


remote func receive_player_spectate_update(player_id: int, is_spectating: bool) -> void:
	if is_rpc_from_server() == false:
		return
	player_list[player_id].spectate = is_spectating
	var setup = get_node_or_null("MenuHandler/Setup")
	if setup:
		setup.update_player_spectating(player_id, is_spectating)


func send_game_option_change(option: String, value: int) -> void:
	if is_host():
		rpc_id(SERVER_ID, "receive_game_option_change", option, value)


remote func receive_game_option_change(option: String, value: int) -> void:
	if is_rpc_from_server() == false:
		return
	game_options[option] = value
	Logger.print(self, "Received game option %s changed to: %d" % [option, value])
	var options = get_node_or_null("MenuHandler/Setup/GameOptions")
	if options:
		match option:
			"goal":
				options.set_goal(value)
			"lives":
				options.set_lives(value)
			"bots":
				options.set_bots(value)
			"difficulty":
				options.set_difficulty(value)
			_:
				push_error("Unrecognised game option: %s" % option)


func send_client_ready() -> void:
	Logger.print(self, "Sending client ready")
	rpc_id(SERVER_ID, "receive_client_ready")


func send_player_flap() -> void:
	rpc_id(SERVER_ID, "receive_player_flap", client_clock)


remote func receive_player_flap(player_id: int, flap_time: int) -> void:
	if player_id == multiplayer.get_network_unique_id():
		# This is the same player who sent it so don't flap again
		return
#	Logger.print(self, "Received flap for player %d @ time = %d" % [player_id, flap_time])
	var player = $World.get_node(str(player_id))
	player.flap_queue.append(flap_time)


func send_player_death(reason: String) -> void:
	rpc_id(SERVER_ID, "receive_player_death", client_clock, reason)


remote func receive_player_death(player_id: int, death_time: int, reason: String) -> void:
	if player_id == multiplayer.get_network_unique_id():
		# This is the same player who sent it so don't call death
		return
	Logger.print(self, "Received death for player %d @ time = %d" % [player_id, death_time])
	var player = $World.get_node(str(player_id))
	player.death("From server - %s" % reason)


remote func receive_player_add_item(player_id: int, item_id: int) -> void:
	var item: Item = Items.get_item(item_id)
	Logger.print(self, "Received add item %d (%s) for player %d" % [item_id, item.name, player_id])
	var player = $World.get_node(str(player_id))
	player.add_item(item)


remote func receive_player_lost_life(lives_left: int) -> void:
	if is_rpc_from_server() == false:
		return
	Logger.print(self, "Received player lost life - remaining = %d" % [lives_left])
	var ui = get_node_or_null("World/UI")
	if ui:
		ui.update_lives(lives_left)


remote func receive_despawn_player(player_id: int) -> void:
	if is_rpc_from_server() == false:
		return
	var world = get_node_or_null("World")
	if world:
		world.despawn_player(player_id)


func send_start_game_request() -> void:
	Logger.print(self, "Sending start game request")
	rpc_id(SERVER_ID, "receive_start_game_request")


remote func receive_setup_info_message(message: String) -> void:
	if is_rpc_from_server() == false:
		return
	var setup = get_node_or_null("MenuHandler/Setup")
	if setup:
		setup.show_message(message)


remote func receive_load_world() -> void:
	if is_rpc_from_server() == false:
		return
	change_scene_to_world()


remote func receive_game_started(
	game_seed: int, start_game_options: Dictionary, start_player_list: Dictionary
) -> void:
	if is_rpc_from_server() == false:
		return
	var world = get_node_or_null("World")
	if world:
		world.start_game(game_seed, start_game_options, start_player_list)


remote func receive_start_countdown() -> void:
	if is_rpc_from_server() == false:
		return
	var world = get_node_or_null("World")
	if world:
		world.start_countdown()


func send_player_state(player_state: Dictionary) -> void:
	rpc_unreliable_id(SERVER_ID, "receive_player_state", player_state)


remote func receive_world_state(world_state: Dictionary) -> void:
	if is_rpc_from_server() == false:
		return
	var world = get_node_or_null("World")
	if world:
		world.update_world_state(world_state)


remote func receive_player_finished_race(player_id: int, place: int, time: float) -> void:
	if is_rpc_from_server() == false:
		return
	var world = get_node_or_null("World")
	if world:
		world.player_finished(player_id, place, time)


remote func receive_leaderboard(leaderboard: Array) -> void:
	if is_rpc_from_server() == false:
		return
	var ui = get_node_or_null("World/UI")
	if ui:
		ui.show_leaderboard(leaderboard)


remote func receive_spawn_object(object_id: int, properties: Dictionary) -> void:
	if is_rpc_from_server() == false:
		return
	var world = get_node_or_null("World")
	if world:
		world.spawn_object(object_id, properties)
