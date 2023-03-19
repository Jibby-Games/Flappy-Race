extends Node


const CLIENT_NETWORK = "res://client/client_network.tscn"
const SERVER_NETWORK = "res://server/server_network.tscn"
const RPC_PORT = 31400
const MAX_PLAYERS = 16
const SERVER_LIST_URL := "http://jibby.games"
const SERVER_MANAGER_URL := "http://jibby.games"

var Client: ClientNetwork
var Server: ServerNetwork

func _load_network_scene(scene_path: String) -> SceneHandler:
	var scene: Node = load(scene_path).instance()
	get_tree().get_root().call_deferred("add_child", scene)
	return scene.get_node("Network") as SceneHandler


func change_to_client() -> void:
	Globals.change_to_client()
	var result: int
	result = get_tree().change_scene(CLIENT_NETWORK)
	assert(result == OK)


func start_singleplayer() -> void:
	if not Server:
		Server = _load_network_scene(SERVER_NETWORK)
		yield(Server, "ready")
	Server.start_server(RPC_PORT, 1, false, "", false)
	Client.start_client("127.0.0.1", RPC_PORT, true)


func start_multiplayer_host(port: int, use_upnp: bool, server_name: String, use_server_list: bool) -> void:
	if not Server:
		Server = _load_network_scene(SERVER_NETWORK)
		yield(Server, "ready")
	Server.start_server(port, MAX_PLAYERS, use_upnp, server_name, use_server_list)
	Client.start_client("127.0.0.1", port)


func start_server(
		port: int,
		use_upnp: bool,
		server_name: String,
		use_server_list: bool,
		use_timeout: bool
	) -> void:
	if not Server:
		Server = _load_network_scene(SERVER_NETWORK)
		yield(Server, "ready")
	Server.start_server(
		port,
		MAX_PLAYERS,
		use_upnp,
		server_name,
		use_server_list,
		use_timeout
	)


func stop_networking() -> void:
	Client.stop_client()
	if Server:
		Server.stop_server()
