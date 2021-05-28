extends SceneHandler


class_name ServerNetwork

# IMPORTANT:
# This node is a Viewport with zero size intentionally in order to separate
# the client and server physics, so objects from the client and the server can't
# interact with eachother when self hosting.

var host_player
var singleplayer := false
var player_state_collection := {}


func _ready() -> void:
	# As you can see, instead of calling get_tree().connect for network related
	# stuff we use mutltiplayer.connect . This way, IF (and only IF) the
	# MultiplayerAPI is customized, we use that instead of the global one.
	# This makes the custom MultiplayerAPI almost plug-n-play.
	assert(multiplayer.connect("network_peer_disconnected", self, "_peer_disconnected") == OK)
	assert(multiplayer.connect("network_peer_connected", self, "_peer_connected") == OK)


func _exit_tree() -> void:
	multiplayer.disconnect("network_peer_disconnected", self, "_peer_disconnected")
	multiplayer.disconnect("network_peer_connected", self, "_peer_connected")


func start_server(port: int, max_players: int) -> void:
	var peer := NetworkedMultiplayerENet.new()
	if singleplayer:
		peer.set_bind_ip("127.0.0.1")
	assert(peer.create_server(port, max_players) == OK)
	# Same goes for things like:
	# get_tree().set_network_peer() -> multiplayer.set_network_peer()
	# Basically, anything networking related needs to be updated this way.
	# See the MultiplayerAPI docs for reference.
	multiplayer.set_network_peer(peer)
	print("[%s] Server started - waiting for players" % [get_path().get_name(1)])


func stop_server() -> void:
	multiplayer.set_network_peer(null)
	print("[%s] Server stopped" % [get_path().get_name(1)])


func _peer_connected(player_id: int) -> void:
	var num_players = multiplayer.get_network_connected_peers().size()
	print("[%s] Player %s connected - %d/%d" %
			[get_path().get_name(1), player_id, num_players, Network.MAX_PLAYERS])
	if host_player == null:
		host_player = player_id
		print("[%s] Player %s is now the host" % [get_path().get_name(1), player_id])
	if singleplayer:
		# Stop any other players joining
		multiplayer.set_refuse_new_network_connections(true)
		# Start the game straight away
		receive_start_game_request()
	else:
		# Tell everyone about the new player
		send_player_list_update()


func _peer_disconnected(player_id: int) -> void:
	print("[%s] Player %s disconnected" % [get_path().get_name(1), player_id])
	if player_id == host_player:
		# Promote the next player to the host if any are still connected
		var peers = multiplayer.get_network_connected_peers()
		if peers.size() > 0:
			var new_host = [0]
			print("[%s] Player %s is now the host" % [get_path().get_name(1), new_host])
			host_player = new_host
		else:
			print("[%s] No host player" % [get_path().get_name(1)])
			host_player = null
	send_despawn_player(player_id)


func send_player_list_update() -> void:
	rpc("receive_player_list_update", multiplayer.get_network_connected_peers())


func send_despawn_player(player_id: int) -> void:
	if player_state_collection.has(player_id):
		assert(player_state_collection.erase(player_id))
	rpc("receive_despawn_player", player_id)


remote func receive_clock_sync_request(client_time: int) -> void:
	var player_id = multiplayer.get_rpc_sender_id()
	rpc_id(player_id, "receive_clock_sync_response", OS.get_system_time_msecs(), client_time)


remote func receive_latency_request(client_time: int) -> void:
	var player_id = multiplayer.get_rpc_sender_id()
	rpc_id(player_id, "receive_latency_response", client_time)


remote func receive_client_ready() -> void:
	var player_id = multiplayer.get_rpc_sender_id()
	$World.set_player_ready(player_id)


remote func receive_start_game_request() -> void:
	# Only the server or the host can start the game
	var player = multiplayer.get_rpc_sender_id()
	if player == 0 or player == host_player:
		print("[%s] Starting game!" % [get_path().get_name(1)])
		send_load_world()
		change_scene("res://server/world/world.tscn")
	else:
		print("[%s] Player %s tried to start the game but they're not the host!" %
				[get_path().get_name(1), player])


func send_load_world() -> void:
	rpc("receive_load_world")


func send_game_started(game_seed: int) -> void:
	rpc("receive_game_started", game_seed)


remote func receive_player_state(player_state: Dictionary) -> void:
	var player_id = multiplayer.get_rpc_sender_id()
	if player_state_collection.has(player_id):
		# Check if the player_state is the latest and replace it if it's newer
		if player_state_collection[player_id]["T"] < player_state["T"]:
			player_state_collection[player_id] = player_state
	else:
		player_state_collection[player_id] = player_state


func send_world_state(world_state: Dictionary) -> void:
	rpc_unreliable("receive_world_state", world_state)
