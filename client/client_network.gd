extends SceneHandler


class_name ClientNetwork


const SERVER_ID := 1


func change_scene_to(scene: PackedScene) -> void:
	print("[CNT] Changing scene to %s" % scene.get_path())
	.change_scene_to(scene)


func _ready() -> void:
	# As you can see, instead of calling get_tree().connect for network related
	# stuff we use mutltiplayer.connect . This way, IF (and only IF) the
	# MultiplayerAPI is customized, we use that instead of the global one.
	# This makes the custom MultiplayerAPI almost plug-n-play.
	assert(multiplayer.connect("connection_failed", self, "_close_network") == OK)
	assert(multiplayer.connect("connected_to_server", self, "_connected") == OK)
	assert(multiplayer.connect("server_disconnected", self, "_close_network") == OK)


func _exit_tree() -> void:
	multiplayer.disconnect("connection_failed", self, "_close_network")
	multiplayer.disconnect("connected_to_server", self, "_connected")
	multiplayer.disconnect("server_disconnected", self, "_close_network")


func start_client(host, port) -> void:
	var peer = NetworkedMultiplayerENet.new()
	peer.create_client(host, port)
	multiplayer.set_network_peer(peer)
	print("[CNT]: Client started")


func stop_client() -> void:
	_close_network()


func _connected() -> void:
	print("[CNT]: Connected to server!")


func _close_network() -> void:
	multiplayer.set_network_peer(null)
	print("[CNT]: Client stopped")


remote func populate_player_list(players: PoolIntArray) -> void:
	var sender = multiplayer.get_rpc_sender_id()
	if sender == SERVER_ID:
		$GameSetup.populate_players(players)
	else:
		print("[CNT]: ERROR Received player list from player %s, is someone hacking?" % sender)


remote func despawn_player(player_id) -> void:
	$World.despawn_player(player_id)


func request_start_game() -> void:
	print("[CNT]: Sending start game request")
	rpc_id(1, "request_start_game")


remote func game_started(game_seed) -> void:
	var sender = multiplayer.get_rpc_sender_id()
	if sender == SERVER_ID:
		change_scene("res://client/world/world.tscn")
		_active_scene.start_game(game_seed)


func send_player_state(player_state : Dictionary) -> void:
	rpc_unreliable_id(1, "send_player_state", player_state)


remote func receive_world_state(world_state: Dictionary) -> void:
	_active_scene.update_world_state(world_state)
