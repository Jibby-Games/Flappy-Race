extends Node


const CLIENT_NETWORK = "res://client/client_network.tscn"
const SERVER_NETWORK = "res://server/server_network.tscn"
const RPC_PORT = 31400
const MAX_PLAYERS = 4


var Client: ClientNetwork
var Server: ServerNetwork


func _ready() -> void:
	if "--server" in OS.get_cmdline_args():
		# The dedicated server shouldn't need any client networking
		Server = _load_network_scene(SERVER_NETWORK)
		Server.start_server(RPC_PORT, MAX_PLAYERS)
	else:
		Client = _load_network_scene(CLIENT_NETWORK)
		Server = _load_network_scene(SERVER_NETWORK)


func _load_network_scene(scene_path: String) -> SceneHandler:
	var scene: Node = load(scene_path).instance()
	get_tree().get_root().call_deferred("add_child", scene)
	return scene.get_node("Network") as SceneHandler
