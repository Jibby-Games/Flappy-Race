extends CommonWorld


var player_ready: Dictionary


func _ready():
	print(get_path(), ": Server world ready!")
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
	print(get_path(), ": All players are ready!")
	return true


func setup_and_start_game():
	print(get_path(), ": Setting up and starting game!")
	var game_seed = randomize_game_seed()
	Network.Server.send_game_started(game_seed)
	start_game(game_seed)


func _on_Player_death(player) -> void:
	Network.Server.send_despawn_player(int(player.name))
	._on_Player_death(player)
