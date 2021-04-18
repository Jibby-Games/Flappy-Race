extends Control


func _ready():
	Net.update_public_ip()
	var _junk = get_tree().connect("connected_to_server", self, "connected")
	# Automatically update the public ip text
	_junk = Net.connect("public_ip_changed", self, "_on_Net_public_ip_changed")


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
