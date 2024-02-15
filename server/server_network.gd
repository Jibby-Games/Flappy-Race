extends SceneHandler

class_name ServerNetwork

const SERVER_ID := 0
const UpnpHandler = preload("res://server/upnp_handler.gd")
const DEFAULT_GAME_OPTIONS := {
	"goal": 50,
	"lives": 0,
	"bots": 8,
	"difficulty": 2,
}
const PLAYER_TIMEOUT_TIME := 20
const BOT_ID_OFFSET := 1000

# IMPORTANT:
# This node is a Viewport with zero size intentionally in order to separate
# the client and server physics, so objects from the client and the server can't
# interact with eachother when self hosting.

var port := 0
var use_tls := false
# When true, the server stays active after all players leave, otherwise it shutsdown
var persistent_server := false
# When true will start a timer and shut down the server if no one joins in time
var player_timeout := false
var max_players := 0
var _host_player_id := 0 setget set_host
var player_state_collection := {}
var player_list := {}
var game_options := {}


func _ready() -> void:
	# As you can see, instead of calling get_tree().connect for network related
	# stuff we use mutltiplayer.connect . This way, IF (and only IF) the
	# MultiplayerAPI is customized, we use that instead of the global one.
	# This makes the custom MultiplayerAPI almost plug-n-play.
	var result: int
	result = multiplayer.connect("network_peer_disconnected", self, "_peer_disconnected")
	assert(result == OK)
	result = multiplayer.connect("network_peer_connected", self, "_peer_connected")
	assert(result == OK)
	result = $ServerListHandler.connect(
		"connection_established", self, "_update_server_list_status"
	)
	assert(result == OK)

	# Register with the Network singleton so this node can be easily accessed
	Network.Server = self


func _exit_tree() -> void:
	multiplayer.disconnect("network_peer_disconnected", self, "_peer_disconnected")
	multiplayer.disconnect("network_peer_connected", self, "_peer_connected")

### Host functions

func set_host(new_host: int) -> void:
	_host_player_id = new_host
	Logger.print(self, "Player %s is now the host" % [_host_player_id])
	rpc("receive_host_change", new_host)


func is_host_id(player_id: int) -> bool:
	return _host_player_id == player_id


func is_host_set() -> bool:
	return _host_player_id != 0


func clear_host() -> void:
	_host_player_id = 0
	Logger.print(self, "Cleared host player")


func start_server(
	server_port: int,
	server_max_players: int,
	forward_port: bool,
	server_name: String,
	use_server_list: bool,
	use_timeout: bool = false
) -> void:
	if OS.has_feature('web'):
		push_error("Server hosting is not supported on browsers!")
		return
	port = server_port
	use_tls = false
	max_players = server_max_players
	game_options = DEFAULT_GAME_OPTIONS.duplicate()
	if forward_port:
		var upnp_handler = UpnpHandler.new()
		upnp_handler.set_name("UpnpHandler")
		add_child(upnp_handler)
		upnp_handler.try_add_port_mapping(port)
	var peer := WebSocketServer.new()
	if Network.X509_CERT and Network.X509_KEY:
		use_tls = true
		peer.private_key = Network.X509_KEY
		peer.ssl_certificate = Network.X509_CERT
	var result: int
	result = peer.listen(port, PoolStringArray(), true)
	assert(result == OK)
	# Same goes for things like:
	# get_tree().set_network_peer() -> multiplayer.set_network_peer()
	# Basically, anything networking related needs to be updated this way.
	# See the MultiplayerAPI docs for reference.
	multiplayer.set_network_peer(peer)
	Logger.print(
		self,
		(
			"Server started on port %d - Name = %s, Max Players = %d, UPnP = %s, Server List = %s, Timeout = %s - waiting for players"
			% [port, server_name, max_players, forward_port, use_server_list, use_timeout]
		)
	)
	populate_bots(0, game_options.bots)
	change_scene_to_setup()
	if use_server_list:
		$ServerListHandler.start_connection(server_name, Network.SERVER_LIST_URL)
	if use_timeout:
		_start_player_timeout()


func _notification(what) -> void:
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		if multiplayer.network_peer != null:
			Logger.print(self, "Got close request, stopping server")
			stop_server()


func stop_server() -> void:
	if $ServerListHandler.connection_started:
		$ServerListHandler.stop_connection()
	if has_node("UpnpHandler"):
		$UpnpHandler.remove_port_mapping()
	clear_host()
	player_state_collection.clear()
	player_list.clear()
	game_options.clear()
	max_players = 0
	port = 0
	if multiplayer.has_network_peer():
		multiplayer.network_peer.stop()
	multiplayer.call_deferred("set_network_peer", null)
	Logger.print(self, "Server stopped")


func change_scene_to_setup() -> void:
	# Flush out old player state
	player_state_collection.clear()
	$StateProcessing.running = false
	change_scene("res://server/setup.tscn")


func _peer_connected(player_id: int) -> void:
	var num_players = multiplayer.get_network_connected_peers().size()
	Logger.print(self, "Player %s connected - %d/%d" % [player_id, num_players, max_players])
	_update_server_list_status()


func _peer_disconnected(player_id: int) -> void:
	var peers = multiplayer.get_network_connected_peers()
	Logger.print(self, "Player %s disconnected - %d/%d" % [player_id, peers.size(), max_players])
	var player_erased = player_list.erase(player_id)
	assert(player_erased)
	if peers.empty():
		# All players disconnected
		if persistent_server:
			# Reset everything ready for future players
			clear_host()
			change_scene_to_setup()
		else:
			stop_server()
			get_tree().quit()
		return
	if is_host_id(player_id):
		# Promote the next player to the host
		var new_host = peers[0]
		set_host(new_host)
	_update_server_list_status()
	send_player_list_update(player_list)
	if has_node("World"):
		$World.despawn_player(player_id)
		send_despawn_player(player_id)


func _update_server_list_status() -> void:
	if $ServerListHandler.is_connected_to_server_list():
		$ServerListHandler.send_players(multiplayer.get_network_connected_peers().size())


func _start_player_timeout() -> void:
	Logger.print(
		self,
		(
			"Timeout started - server will shutdown if no one joins within %s seconds..."
			% PLAYER_TIMEOUT_TIME
		)
	)
	yield(get_tree().create_timer(PLAYER_TIMEOUT_TIME), "timeout")
	if multiplayer.get_network_connected_peers().size() == 0:
		Logger.print(self, "No players joined! Shutting down the server...")
		stop_server()
		get_tree().quit()


remote func receive_change_to_setup_request() -> void:
	var player_id = multiplayer.get_rpc_sender_id()
	if not is_host_id(player_id):
		Logger.print(
			self, "Player %s tried to go back to setup but they're not the host!" % [player_id]
		)
		return
	Logger.print(self, "Player %s requested change to setup scene" % [player_id])
	change_scene_to_setup()
	send_change_to_setup()


func send_change_to_setup() -> void:
	rpc("receive_change_to_setup")


remote func receive_host_change_request(new_host_id: int) -> void:
	var player_id = multiplayer.get_rpc_sender_id()
	if not is_host_id(player_id):
		Logger.print(
			self, "Player %s tried to request host change but they're not the host!" % [player_id]
		)
		return
	Logger.print(self, "Player %s changed host to player %s" % [player_id, new_host_id])
	set_host(new_host_id)


remote func receive_kick_request(kick_player_id: int) -> void:
	var player_id = multiplayer.get_rpc_sender_id()
	if not is_host_id(player_id):
		Logger.print(
			self, "Player %s tried to kick player %s but they're not the host!" % [player_id, kick_player_id]
		)
		return
	Logger.print(self, "Player %s kicked player %s" % [player_id, kick_player_id])
	kick_player(kick_player_id)


func kick_player(player_id: int) -> void:
	Logger.print(self, "Kicked player %s" % player_id)
	rpc_id(player_id, "receive_player_kicked")
	yield(get_tree().create_timer(1), "timeout")
	# Just in case the player doesn't get the kicked message
	if player_id in multiplayer.get_network_connected_peers():
		multiplayer.network_peer.disconnect_peer(player_id)


remote func receive_player_settings(player_name: String, player_colour: int) -> void:
	var player_id = multiplayer.get_rpc_sender_id()
	Logger.print(
		self,
		"Got settings for player %s. Name: %s, Colour: %s" % [player_id, player_name, player_colour]
	)
	if does_name_already_exist(player_name):
		player_name = rename_player(player_name)
		Logger.print(self, "Player %s renamed to %s" % [player_id, player_name])
	if not is_host_set():
		# Set the initial host
		set_host(player_id)
	var game_started := has_node("World")
	player_list[player_id] = create_player_list_entry(player_name, player_colour, game_started)
	send_game_info_to(player_id)
	send_player_list_update(player_list)
	if game_started:
		send_late_join_info_to(player_id)
	# Client will already load setup scene if game hasn't started yet


func does_name_already_exist(player_name: String) -> bool:
	for player_entry in player_list.values():
		if player_entry.name == player_name:
			return true
	return false


func rename_player(player_name: String) -> String:
	var regex := RegEx.new()
	# Finds any numbers at the end of the string
	var compile := regex.compile("(.*?)(\\d*)$")
	assert(compile == OK)
	var result := regex.search(player_name)
	var main_name := result.get_string(1)
	var number_suffix := result.get_string(2)
	var new_number := int(number_suffix) + 1
	player_name = "%s%d" % [main_name, new_number]
	while does_name_already_exist(player_name):
		player_name = "%s%d" % [main_name, new_number]
		new_number += 1
	return player_name


func send_game_info_to(player_id: int) -> void:
	Logger.print(self, "Sending initial game info to player %s" % [player_id])
	rpc_id(player_id, "receive_game_info", _host_player_id, player_list, game_options)


func create_player_list_entry(
	player_name: String, player_colour: int, spectating: bool, bot: bool = false
) -> Dictionary:
	return {
		"name": player_name,
		"colour": player_colour,
		"spectate": spectating,
		"bot": bot,
		"body": null,
		"score": 0,
	}


func send_player_list_update(new_player_list: Dictionary) -> void:
	Logger.print(self, "Sending player list update")
	rpc("receive_player_list_update", new_player_list)


func send_late_join_info_to(player_id: int) -> void:
	rpc_id(player_id, "receive_late_join_info", $World.game_seed, $World.time)


remote func receive_player_colour_change(colour_choice: int) -> void:
	var player_id = multiplayer.get_rpc_sender_id()
	player_list[player_id]["colour"] = colour_choice
	Logger.print(self, "Player %s chose colour %s " % [player_id, colour_choice])
	send_player_colour_update(player_id, colour_choice)


func send_player_colour_update(player_id: int, colour_choice: int) -> void:
	Logger.print(self, "Sending player colour update")
	rpc("receive_player_colour_update", player_id, colour_choice)


remote func receive_player_spectate_change(is_spectating: bool) -> void:
	var player_id = multiplayer.get_rpc_sender_id()
	player_list[player_id]["spectate"] = is_spectating
	Logger.print(self, "Player %s set spectating to %s " % [player_id, is_spectating])
	send_player_spectate_update(player_id, is_spectating)


func send_player_spectate_update(player_id: int, is_spectating: bool) -> void:
	Logger.print(self, "Sending player spectate update")
	rpc("receive_player_spectate_update", player_id, is_spectating)


remote func receive_game_option_change(option: String, value: int) -> void:
	var player_id = multiplayer.get_rpc_sender_id()
	if not is_host_id(player_id):
		Logger.print(
			self, "Player %s tried to change %s to %d but they're not the host!" % [player_id, option, value]
		)
		# Reset clients back to server value
		rpc("receive_game_options", game_options)
		return
	if not is_option_valid(option, value):
		push_error("Player %s tried to set %s to invalid value: %d" % [player_id, option, value])
		# Reset clients back to server value
		rpc("receive_game_options", game_options)
		return
	if option == "bots":
		populate_bots(game_options.bots, value)
	game_options[option] = value
	Logger.print(self, "Player %s set %s to %s" % [player_id, option, value])
	for connected_player_id in multiplayer.get_network_connected_peers():
		# Don't send update to the host again to stop infinite update loops from lag
		if not is_host_id(connected_player_id):
			rpc_id(connected_player_id, "receive_game_option_change", option, value)


func is_option_valid(option: String, value: int) -> bool:
	match option:
		"goal":
			return value >= 1 or value <= 1000
		"lives":
			return value >= 0 or value <= 1000
		"bots":
			return value >= 0 or (value + multiplayer.get_network_connected_peers().size()) <= Network.MAX_PLAYERS
		"difficulty":
			return value in CommonWorld.Difficulty.values()
		_:
			push_error("Unrecognised game option: %s" % option)
			return false


func populate_bots(old_bots: int, new_bots: int) -> void:
	if old_bots == new_bots:
		# No change
		return
	if new_bots > old_bots:
		var bots_to_add := new_bots - old_bots
		Logger.print(self, "Adding %d bots" % bots_to_add)
		for i in bots_to_add:
			var bot_id: int = old_bots + i + BOT_ID_OFFSET
			# TODO add bot name generator
			var bot_name := "Bot%d" % [bot_id]
			var bot_colour: int = Globals.get_random_colour_id()
			player_list[bot_id] = create_player_list_entry(bot_name, bot_colour, false, true)
	else:
		var bots_to_remove := old_bots - new_bots
		Logger.print(self, "Removing %d bots" % bots_to_remove)
		for i in bots_to_remove:
			var bot_id: int = new_bots + i + BOT_ID_OFFSET
			var bot_erased := player_list.erase(bot_id)
			assert(bot_erased)
	send_player_list_update(player_list)


func send_player_lost_life(player_id: int, lives_left: int) -> void:
	rpc_id(player_id, "receive_player_lost_life", lives_left)


func send_despawn_player(player_id: int) -> void:
	var erased = player_state_collection.erase(player_id)
	assert(erased)
	rpc("receive_despawn_player", player_id)


remote func receive_clock_sync_request(client_time: int) -> void:
	var player_id = multiplayer.get_rpc_sender_id()
	rpc_id(player_id, "receive_clock_sync_response", OS.get_system_time_msecs(), client_time)


remote func receive_latency_request(client_time: int) -> void:
	var player_id = multiplayer.get_rpc_sender_id()
	rpc_id(player_id, "receive_latency_response", client_time)


remote func receive_client_ready() -> void:
	var player_id = multiplayer.get_rpc_sender_id()
	Logger.print(self, "Received client ready for %s" % [player_id])
	$World.set_player_ready(player_id)


remote func receive_start_game_request() -> void:
	# Only the server or the host can start the game
	var player_id = multiplayer.get_rpc_sender_id()
	if player_id == SERVER_ID or is_host_id(player_id):
		if player_list.empty():
			Logger.print(self, "Cannot start game without any players!")
			send_setup_info_message("Not enough players!")
			return
		if is_everyone_spectating():
			Logger.print(self, "Cannot start game with just spectators!")
			send_setup_info_message("Too many spectators!")
			return
		Logger.print(self, "Starting game!")
		# Flush any old states
		player_state_collection.clear()
		$StateProcessing.running = true
		send_load_world()
		change_scene("res://server/world/world.tscn")
	else:
		Logger.print(
			self, "Player %s tried to start the game but they're not the host!" % [player_id]
		)


func send_setup_info_message(message: String) -> void:
	rpc("receive_setup_info_message", message)


func is_everyone_spectating() -> bool:
	for player in player_list.values():
		if player.spectate == false:
			return false
	return true


func send_load_world() -> void:
	rpc("receive_load_world")


func send_game_started(game_seed: int) -> void:
	rpc("receive_game_started", game_seed, game_options, player_list)


func send_start_countdown() -> void:
	rpc("receive_start_countdown")


remote func receive_player_flap(client_clock: int) -> void:
	var player_id = multiplayer.get_rpc_sender_id()
	if not $World.has_node(str(player_id)):
		push_error("Flap received for player %s - but can't find player in world")
		return
#	Logger.print(self, "Received flap for player %d" % player_id)
	send_player_flap(player_id, client_clock)


func send_player_flap(player_id: int, clock_time: int) -> void:
	rpc_id(0, "receive_player_flap", player_id, clock_time)


remote func receive_player_death(client_clock: int, reason: String) -> void:
	var player_id = multiplayer.get_rpc_sender_id()
	if not $World.has_node(str(player_id)):
		push_error("Death received for player %s - but can't find player in world")
		return
	Logger.print(self, "Received death for player %d" % player_id)
	var player := $World.get_node(str(player_id))
	player.death("From client - %s" % reason)
	send_player_death(player_id, client_clock, reason)


func send_player_death(player_id: int, clock_time: int, reason: String) -> void:
	rpc_id(0, "receive_player_death", player_id, clock_time, reason)


remote func receive_player_state(player_state: Dictionary) -> void:
	var player_id = multiplayer.get_rpc_sender_id()
	add_player_state(player_id, player_state)


func add_player_state(player_id: int, player_state: Dictionary) -> void:
	if player_state_collection.has(player_id):
		# Check if the player_state is the latest and replace it if it's newer
		if player_state_collection[player_id]["T"] < player_state["T"]:
			player_state_collection[player_id] = player_state
	else:
		player_state_collection[player_id] = player_state


func send_world_state(world_state: Dictionary) -> void:
	rpc_unreliable("receive_world_state", world_state)


func send_player_finished_race(player_id: int, place: int, time: float) -> void:
	rpc("receive_player_finished_race", player_id, place, time)


func send_leaderboard(leaderboard: Array) -> void:
	rpc("receive_leaderboard", leaderboard)


func send_player_add_item(player_id: int, item_id: int) -> void:
	rpc("receive_player_add_item", player_id, item_id)


func send_spawn_object(object_id: int, properties: Dictionary) -> void:
	rpc("receive_spawn_object", object_id, properties)
