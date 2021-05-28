extends Node


const CLIENT_NETWORK = "res://client/client_network.tscn"
const SERVER_NETWORK = "res://server/server_network.tscn"
const RPC_PORT = 31400
const MAX_PLAYERS = 4


var Client: ClientNetwork
var Server: ServerNetwork


func _load_network_scene(scene_path: String) -> SceneHandler:
	var scene: Node = load(scene_path).instance()
	get_tree().get_root().call_deferred("add_child", scene)
	return scene.get_node("Network") as SceneHandler


func start_singleplayer() -> void:
	Server = _load_network_scene(SERVER_NETWORK)
	yield(Server, "ready")
	Server.singleplayer = true
	Server.start_server(RPC_PORT, MAX_PLAYERS)
	Client.start_client("127.0.0.1", RPC_PORT)


func start_multiplayer() -> void:
	Server = _load_network_scene(SERVER_NETWORK)
	yield(Server, "ready")
	Server.start_server(RPC_PORT, MAX_PLAYERS)
	Client.start_client("127.0.0.1", RPC_PORT)
