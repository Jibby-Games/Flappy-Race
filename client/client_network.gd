extends Node

const RPC_PORT = 31400
const SERVER_IP = "127.0.0.1"


func _ready():
	# As you can see, instead of calling get_tree().connect for network related
	# stuff we use mutltiplayer.connect . This way, IF (and only IF) the
	# MultiplayerAPI is customized, we use that instead of the global one.
	# This makes the custom MultiplayerAPI almost plug-n-play.
	multiplayer.connect("connection_failed", self, "_close_network")
	multiplayer.connect("connected_to_server", self, "_connected")
	multiplayer.connect("server_disconnected", self, "_close_network")


func _exit_tree():
	multiplayer.disconnect("connection_failed", self, "_close_network")
	multiplayer.disconnect("connected_to_server", self, "_connected")
	multiplayer.disconnect("server_disconnected", self, "_close_network")


func start_client(host, port):
	var peer = NetworkedMultiplayerENet.new()
	peer.create_client(host, port)
	multiplayer.set_network_peer(peer)
	print("Client started")


func _on_JoinServer_pressed():
	start_client(SERVER_IP, RPC_PORT)


func _connected():
	print("Connected to server!")


func _close_network():
	multiplayer.set_network_peer(null)
	print("Networking stopped")


func request_something():
	var x = 19
	print("UID ", multiplayer.get_network_unique_id(), " requesting with: ", x)
	rpc_id(1, "process_something", x)


remote func receive_something(x):
	print("UID ", multiplayer.get_network_unique_id(), " received: ", x)


func _on_SendRPC_pressed():
	request_something()
