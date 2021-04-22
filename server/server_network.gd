extends SceneHandler


class_name ServerNetwork


var host_player
var singleplayer := false


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


func start_server(port, max_players) -> void:
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(port, max_players)
	# Same goes for things like:
	# get_tree().set_network_peer() -> multiplayer.set_network_peer()
	# Basically, anything networking related needs to be updated this way.
	# See the MultiplayerAPI docs for reference.
	multiplayer.set_network_peer(peer)
	print("[SRV]: Server started - waiting for players")


func stop_server() -> void:
	multiplayer.set_network_peer(null)
	print("[SRV]: Server stopped")


func _peer_connected(player_id) -> void:
	var num_players = multiplayer.get_network_connected_peers().size()
	print("[SRV]: Player %s connected - %d/%d" %
			[player_id, num_players, Network.MAX_PLAYERS])
	if host_player == null:
		host_player = player_id
		print("[SRV]: Player %s is now the host" % player_id)
	if !singleplayer:
		# Tell everyone about the new player
		rpc("populate_player_list", multiplayer.get_network_connected_peers())


func _peer_disconnected(player_id) -> void:
	print("[SRV]: Player %s disconnected" % player_id)
	if player_id == host_player:
		# Promote the next player to the host if any are still connected
		var peers = multiplayer.get_network_connected_peers()
		if peers.size() > 0:
			var new_host = [0]
			print("[SRV]: Player %s is now the host" % new_host)
			host_player = new_host


remote func start_game() -> void:
	# Only the host can start the game
	var player = multiplayer.get_rpc_sender_id()
	if player == host_player:
		print("[SRV]: Starting game!")
		rpc("game_started")
		Network.Server.change_scene("res://server/world/world.tscn")
	else:
		print("[SRV]: Player %s tried to start the game but they're not the host!" % player)


remote func player_flapped() -> void:
	var player_id = multiplayer.get_rpc_sender_id()
	print("[SRV] Player %s flapped!" % player_id)
