extends Node

const CLIENT_NETWORK = "res://client/client_network.tscn"
const SERVER_NETWORK = "res://server/server_network.tscn"
const RPC_PORT = 31400
const MAX_PLAYERS = 16
const SERVER_LIST_URL := "https://jibby.games"
const SERVER_MANAGER_URL := "https://jibby.games"

var Client: ClientNetwork
var Server: ServerNetwork

var X509_CERT_PATH := "user://certs/X509_certificate.crt"
var X509_KEY_PATH := "user://certs/X509_key.key"
var X509_CERT: Resource
var X509_KEY: Resource


# Checks if any certs are present and loads them to enable secure WebSocket connections
func load_certs() -> void:
	var dir = Directory.new()
	if not dir.file_exists(X509_CERT_PATH):
		Logger.print(self, "No X509 cert detected - skipping cert loading")
		return
	if not dir.file_exists(X509_KEY_PATH):
		Logger.print(self, "No X509 key detected - skipping cert loading")
		return
	X509_CERT = load(X509_CERT_PATH)
	X509_KEY = load(X509_KEY_PATH)
	Logger.print(self, "Successfully loaded X509 certs!")


func _load_network_scene(scene_path: String) -> SceneHandler:
	var scene: Node = load(scene_path).instance()
	get_tree().get_root().call_deferred("add_child", scene)
	return scene.get_node("Network") as SceneHandler


func change_to_client() -> void:
	Globals.change_to_client()
	var result: int
	result = get_tree().change_scene(CLIENT_NETWORK)
	assert(result == OK)


func start_client(host: String, port: int) -> void:
	if not Client:
		change_to_client()
		yield(get_tree(), "idle_frame")
	Network.Client.change_scene_to_lobby()
	Network.Client.start_client(host, port)


func start_singleplayer() -> void:
	if not Server:
		Server = _load_network_scene(SERVER_NETWORK)
		yield(Server, "ready")
	Server.start_server(RPC_PORT, 1, false, "", false)
	Client.start_client("ws://127.0.0.1", RPC_PORT, true)


func start_multiplayer_host(
	port: int, use_upnp: bool, server_name: String, use_server_list: bool
) -> void:
	if not Client:
		change_to_client()
		yield(get_tree(), "idle_frame")
		Network.Client.change_scene_to_lobby()
	if not Server:
		Server = _load_network_scene(SERVER_NETWORK)
		yield(Server, "ready")
	Server.start_server(port, MAX_PLAYERS, use_upnp, server_name, use_server_list)
	Client.start_client("ws://127.0.0.1", port)


func start_server(
	port: int, use_upnp: bool, server_name: String, use_server_list: bool, use_timeout: bool
) -> void:
	if not Server:
		Server = _load_network_scene(SERVER_NETWORK)
		yield(Server, "ready")
	Server.start_server(port, MAX_PLAYERS, use_upnp, server_name, use_server_list, use_timeout)


func stop_networking() -> void:
	Client.stop_client()
	if Server:
		Server.stop_server()
