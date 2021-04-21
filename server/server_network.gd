extends Node

const RPC_PORT = 31400
const MAX_PLAYERS = 4


func _ready():
	# As you can see, instead of calling get_tree().connect for network related
	# stuff we use mutltiplayer.connect . This way, IF (and only IF) the
	# MultiplayerAPI is customized, we use that instead of the global one.
	# This makes the custom MultiplayerAPI almost plug-n-play.
	multiplayer.connect("network_peer_disconnected", self, "_peer_disconnected")
	multiplayer.connect("network_peer_connected", self, "_peer_connected")
	start_server(RPC_PORT)


func _exit_tree():
	multiplayer.disconnect("network_peer_disconnected", self, "_peer_disconnected")
	multiplayer.disconnect("network_peer_connected", self, "_peer_connected")


func start_server(port):
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(port)
	# Same goes for things like:
	# get_tree().set_network_peer() -> multiplayer.set_network_peer()
	# Basically, anything networking related needs to be updated this way.
	# See the MultiplayerAPI docs for reference.
	multiplayer.set_network_peer(peer)
	print("Server started")


func _peer_connected(player_id):
	print("Player ", player_id, " connected")
	var newClient = Node.new()
	newClient.set_name(str(player_id))  # spawn players with their respective names
	add_child(newClient)


func _peer_disconnected(player_id):
	print("Player ", player_id, " disconnected")


remote func process_something(x):
	var player_id = multiplayer.get_rpc_sender_id()
	print(
		"UID ",
		multiplayer.get_network_unique_id(),
		" is processing a request from player ",
		player_id,
		" with: ",
		x
	)
	rpc_id(player_id, "receive_something", x + 1)
