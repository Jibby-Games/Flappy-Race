extends Control

enum ConnType {HOST=0, CLIENT=1}

func _ready():
	Net.update_public_ip()
	assert(get_tree().connect("connected_to_server", self, "connected") == OK)
	# Automatically update the public ip text
	assert(Net.connect("public_ip_changed", self, "_on_Net_public_ip_changed") == OK)


func connected():
	if Net.is_host:
		if Net.current_players == Net.MAX_PLAYERS:
			start_game()
		else:
			$Connecting/NumPlayers.text = "Players: [%d/%d]" % [Net.current_players, Net.MAX_PLAYERS]
	else:
		# Tell the server that I, a player, joined.
		rpc_id(0, "player_joined")


remote func player_joined():
	Net.current_players += 1
	connected()


remotesync func begin_game(new_seed):
	# Sync up the RNG seed for all players
	Globals.set_game_seed(new_seed)
	SceneManager.change_to(Enums.Scene.WORLD)


func start_game():
	# Randomize the seed and start the game with it
	var new_seed = Globals.randomize_game_seed()
	rpc("begin_game", new_seed)


func _on_BGMusic_finished():
	pass #$BGMusic.play()


func _on_Start_pressed():
	start_game()


func _on_Net_public_ip_changed(new_ip):
	# Update IPs
	$Connecting/MyIP.text = "IP: " + new_ip
	$Host/MyIP.text = "IP: " + new_ip


func _on_Back_pressed():
	SceneManager.change_to(Enums.Scene.TITLE)


func _on_Solo_pressed():
	# Tell the game to start in offline mode
	Net.is_online = false
	assert(Globals.randomize_game_seed())
	# And start the actual game
	SceneManager.change_to(Enums.Scene.WORLD)


func on_Host_pressed():
	Net.initialise_server()
	show_connect_screen(ConnType.HOST)


# Connected to the pressed() signal.
func _on_Join_pressed():
	if $Join/JoinIP.text.is_valid_ip_address():
		$Join/InvalidIP.hide()
		join()
	else:
		$Join/InvalidIP.show()

func join():
	var join_ip = $Join/JoinIP.text
	Net.initialise_client(join_ip)
	show_connect_screen(ConnType.CLIENT)


# This function is called when the join or host buttons are pushed.
# It should ONLY handle changing the screen for the user.
func show_connect_screen(conn_type):
	# Reveal thyself
	$Connecting.show()

	if conn_type == ConnType.HOST:
		$Connecting/ConnectingText.text = "Waiting for players..."
		$Connecting/NumPlayers.text = "Players: [%d/%d]" % [Net.current_players, Net.MAX_PLAYERS]
		$Connecting/MyIP.show()
		$Connecting/Start.show()
		$Connecting/NumPlayers.show()

	elif conn_type == ConnType.CLIENT:
		$Connecting/ConnectingText.text = "...Connecting to server..."
