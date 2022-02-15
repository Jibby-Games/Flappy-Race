extends Node


const CLIENT_NETWORK = "res://client/client_network.tscn"
const SERVER_NETWORK = "res://server/server_network.tscn"
const RPC_PORT = 31400
const MAX_PLAYERS = 16


var Client: ClientNetwork
var Server: ServerNetwork


func _ready() -> void:
	parse_command_line_args()


func parse_command_line_args() -> void:
	# Make sure at least one of the two is set before continuing
	if Client == null or Server == null:
		yield(get_tree(), "idle_frame")

	# Server options
	var is_server := false

	# Client options
	var host_game := false
	var join_ip := ""

	# Hosting options
	var port := RPC_PORT
	var use_upnp := false

	var args := OS.get_cmdline_args()
	for arg_index in args.size():
		var arg = args[arg_index]
		if arg == "--server":
			is_server = true
		elif arg == "--host":
			host_game = true
		elif arg == "--join":
			join_ip = args[arg_index + 1]
			if ":" in join_ip:
				var parts := join_ip.split(":")
				join_ip = parts[0]
				port = int(parts[1])
		elif arg == "--port":
			port = int(args[arg_index + 1])
		elif arg == "--upnp":
			use_upnp = true

	if is_server:
		start_server(port, use_upnp)
	else:
		if host_game:
			Client.change_scene_to_lobby()
			start_multiplayer_host(port, use_upnp)
		elif join_ip.empty() == false:
			Client.change_scene_to_lobby()
			Client.start_client(join_ip, port)


func _load_network_scene(scene_path: String) -> SceneHandler:
	var scene: Node = load(scene_path).instance()
	get_tree().get_root().call_deferred("add_child", scene)
	return scene.get_node("Network") as SceneHandler


func change_to_client() -> void:
	Globals.change_to_client()
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


func start_multiplayer_host(port: int = RPC_PORT, use_upnp: bool = false) -> void:
	if not Server:
		Server = _load_network_scene(SERVER_NETWORK)
		yield(Server, "ready")
	Server.start_server(port, MAX_PLAYERS, use_upnp)
	Client.start_client("127.0.0.1", port)


func start_server(port: int = RPC_PORT, use_upnp: bool = false) -> void:
	if not Server:
		Server = _load_network_scene(SERVER_NETWORK)
		yield(Server, "ready")
	Server.start_server(port, MAX_PLAYERS, use_upnp)


func stop_networking() -> void:
	Client.stop_client()
	if Server:
		Server.stop_server()
