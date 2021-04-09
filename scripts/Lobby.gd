extends Control


func _ready():
	get_tree().connect("connected_to_server", self, "connected")

func connected():
	print("Connected!")
	if Net.is_host and Net.current_players == Net.MAX_PLAYERS:
		
		## TODO: Set the random seed here, and broadcast it to all players before the game starts
		rpc("begin_game")
		begin_game()
	else:
		if not Net.is_host:
			rpc_id(0, "player_joined")

remote func player_joined():
	print("PLAYER CONNECTED")
	Net.current_players += 1
	connected()
	

remote func begin_game():
	print("Remote begin")
	get_tree().change_scene("res://scenes/World.tscn")
	
