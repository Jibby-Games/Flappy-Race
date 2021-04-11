extends Control


func _ready():
	var _junk = get_tree().connect("connected_to_server", self, "connected")

func connected():
	if Net.is_host:
		if Net.current_players == Net.MAX_PLAYERS:
			# Send the start_game signal
			rpc("begin_game")
		else:
			$Connecting/NumPlayers.text = "Players: [%d/%d]" % [Net.current_players, Net.MAX_PLAYERS]
	else:
		if not Net.is_host:
			# Tell the server that I, a player, joined.
			rpc_id(0, "player_joined")

remote func player_joined():
	Net.current_players += 1
	connected()

remotesync func begin_game():
	## TODO: Set the random seed here, and broadcast it to all players before the game starts
	var _junk = get_tree().change_scene("res://scenes/World.tscn")

remote func join_game():
	var _junk = get_tree().change_scene("res://scenes/World.tscn")

func _on_Start_pressed():
	rpc("begin_game")
