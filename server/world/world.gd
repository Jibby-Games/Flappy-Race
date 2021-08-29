extends CommonWorld


var player_ready: Dictionary


func _ready():
	for player_id in multiplayer.get_network_connected_peers():
		# The server isn't a player
		if player_id != 1:
			player_ready[player_id] = false


func set_player_ready(player_id: int) -> void:
	player_ready[player_id] = true
	if is_everyone_ready():
		setup_and_start_game()


func is_everyone_ready() -> bool:
	for ready_state in player_ready.values():
		if ready_state == false:
			# At least one player was not ready
			return false
	print("[%s] All players are ready!" % [get_path().get_name(1)])
	return true


func setup_and_start_game():
	print("[%s] Setting up and starting game!" % [get_path().get_name(1)])
	var game_seed = randomize_game_seed()
	Network.Server.send_game_started(game_seed)
	start_game(game_seed, Network.Server.player_list)


func _on_Player_death(player: Node2D) -> void:
	print("[%s] Detected player death for %s!" % [get_path().get_name(1), player.name])
	Network.Server.send_despawn_player(int(player.name))
	._on_Player_death(player)
