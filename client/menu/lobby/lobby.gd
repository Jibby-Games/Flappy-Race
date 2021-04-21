extends Control


const MAX_CONNECT_TIME := 5

#enum ConnType {HOST=0, CLIENT=1}

func _ready() -> void:
	assert(multiplayer.connect("connected_to_server", self, "_on_connected") == OK)

#func connected():
#	if Net.is_host:
#		if Net.current_players == Net.MAX_PLAYERS:
#			start_game()
#		else:
#			$Connecting/NumPlayers.text = "Players: [%d/%d]" % [Net.current_players, Net.MAX_PLAYERS]
#	else:
	# Tell the server that I, a player, joined.
#	rpc_id(0, "player_joined")


#remote func player_joined():
#	Net.current_players += 1
#	connected()


remotesync func begin_game(new_seed):
	# Sync up the RNG seed for all players
	Globals.set_game_seed(new_seed)
	# FIXME: load world as subscene
#	SceneManager.change_to(Enums.Scene.WORLD)


func start_game():
	# Randomize the seed and start the game with it
	var new_seed = Globals.randomize_game_seed()
#	rpc("begin_game", new_seed)


func _on_BGMusic_finished():
	pass #$BGMusic.play()


func _on_Start_pressed():
	start_game()



func _on_Back_pressed():
	Network.Client.change_scene("res://client/menu/title/title_screen.tscn")


func on_Host_pressed():
	Network.Server.start_server(Network.RPC_PORT, Network.MAX_PLAYERS)
	Network.Client.start_client("127.0.0.1", Network.RPC_PORT)
	Network.Client.change_scene("res://client/menu/lobby/game_setup.tscn")


# Connected to the pressed() signal.
func _on_Join_pressed():
	$ErrorMessage.text = "Connecting..."
	$ErrorMessage.show()
	var join_ip = $Join/JoinIP.text
	if join_ip.is_valid_ip_address():
		$Join/InvalidIP.hide()
		try_connect_to_server(join_ip)
	else:
		$Join/InvalidIP.show()

func try_connect_to_server(ip: String):
	$ConnectionTimer.start(MAX_CONNECT_TIME)
	Network.Client.start_client(ip, Network.RPC_PORT)


func _on_connected() -> void:
	$ConnectionTimer.stop()
	Network.Client.change_scene("res://client/menu/lobby/game_setup.tscn")


func _on_ConnectionTimer_timeout():
	print("[CNT]: Connection timed out!")
	Network.Client.stop_client()
	$ErrorMessage.text = "Failed to connect!"
	$ErrorMessage.show()
