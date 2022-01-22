extends CommonWorld


var highest_score := 0
var player_ready: Dictionary
var next_place := 1


func _ready() -> void:
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
	Logger.print(self, "All players are ready!")
	return true


func setup_and_start_game() -> void:
	Logger.print(self, "Setting up and starting game!")
	var game_seed = randomize_game_seed()
	var goal = Network.Server.game_options.goal
	Network.Server.send_game_started(game_seed, goal)
	start_game(game_seed, goal, Network.Server.player_list)


func _on_Player_death(player: CommonPlayer) -> void:
	Logger.print(self, "Detected player death for %s!" % [player.name])
	Network.Server.send_despawn_player(int(player.name))
	._on_Player_death(player)


func _on_Player_score_point(player: CommonPlayer) -> void:
	var player_id = int(player.name)
	Logger.print(self, "Player %s scored a point!" % [player_id])
	player_list[player_id].score = player.score
	if player.score > highest_score:
		# Make the walls spawn as players progress
		highest_score = player.score
		spawn_wall()
		Network.Server.send_spawn_wall()


func _on_Player_finish(player: CommonPlayer) -> void:
	# Store the place immediately in case the funciton gets called multiple times while it's running
	var place := next_place
	next_place += 1
	var player_id := int(player.name)
	player_list[player_id].place = place
	Network.Server.send_player_finished_race(player_id, place)
	._on_Player_finish(player)


func end_race() -> void:
	var leaderboard := []
	for player_id in player_list:
		var player = player_list[player_id]
		if player.spectate:
			continue
		var entry = {
			"name": player.name,
			"colour": player.colour,
			"place": player.place,
			"score": player.score
		}
		# Should sort the order out
		if player.place:
			leaderboard.insert(player.place - 1, entry)
		else:
			leaderboard.push_back(entry)
	Network.Server.send_leaderboard(leaderboard)
	Logger.print(self, "Server Leaderboard: %s" % [leaderboard])
