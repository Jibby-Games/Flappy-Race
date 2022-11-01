extends Node

# This node is only needs to detect the command line args so the right scene can be loaded
func _ready() -> void:
	parse_command_line_args()


func parse_command_line_args() -> void:
	# Server options
	var is_server := OS.has_feature("Server")

	# Client options
	var host_game := false
	var join_ip := ""

	# Hosting options
	var port := Network.RPC_PORT
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
		Logger.print(self, "Starting Server...")
		Network.start_server(port, use_upnp)
	else:
		Logger.print(self, "Starting Client...")
		Network.change_to_client()
		if host_game:
			Network.Client.change_scene_to_lobby()
			Network.start_multiplayer_host(port, use_upnp)
		elif join_ip.empty() == false:
			Network.Client.change_scene_to_lobby()
			Network.Client.start_client(join_ip, port)
