extends Node


const CLIENT_NETWORK = "res://client/client_network.tscn"
const SERVER_NETWORK = "res://server/server_network.tscn"
const RPC_PORT = 31400
const MAX_PLAYERS = 16


var Client: ClientNetwork
var Server: ServerNetwork


func _load_network_scene(scene_path: String) -> SceneHandler:
	var scene: Node = load(scene_path).instance()
	get_tree().get_root().call_deferred("add_child", scene)
	return scene.get_node("Network") as SceneHandler


func change_to_client() -> void:
	var result: int
	result = get_tree().change_scene(CLIENT_NETWORK)
	assert(result == OK)


func change_to_server() -> void:
	var result: int
	result = get_tree().change_scene(SERVER_NETWORK)
	assert(result == OK)


func start_singleplayer() -> void:
	if not Server:
		Server = _load_network_scene(SERVER_NETWORK)
		yield(Server, "ready")
	Server.start_server(RPC_PORT, 1, false)
	Client.start_client("127.0.0.1", RPC_PORT, true)


func start_multiplayer_host(use_upnp: bool) -> void:
	if not Server:
		Server = _load_network_scene(SERVER_NETWORK)
		yield(Server, "ready")
	Server.start_server(RPC_PORT, MAX_PLAYERS, use_upnp)
	Client.start_client("127.0.0.1", RPC_PORT)


func stop_networking() -> void:
	Client.stop_client()
	if Server:
		Server.stop_server()
