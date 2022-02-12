extends CommonWorld


var highest_score := 0
var player_ready: Dictionary
var next_place := 1
var players
var player_lives := {}
var players_died := []
var players_finished := []


# Timing
var time_running := false
var time := 0.0


func _ready() -> void:
	for player_id in multiplayer.get_network_connected_peers():
		# The server isn't a player
		if player_id != 1:
			player_ready[player_id] = false


func _process(delta: float) -> void:
	if time_running:
		time += delta


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
	Network.Server.send_game_started(game_seed)
	start_game(game_seed, Network.Server.game_options, Network.Server.player_list)


func start_game(game_seed: int, new_game_options: Dictionary, new_player_list: Dictionary) -> void:
	.start_game(game_seed, new_game_options, new_player_list)
	# Countdown
	yield(get_tree().create_timer(3), "timeout")
	time_running = true


func reset_players() -> void:
	if game_options.lives > 0:
		player_lives.clear()
	.reset_players()


func spawn_player(player_id: int, spawn_position: Vector2) -> Node2D:
	if game_options.lives > 0:
		player_lives[player_id] = game_options.lives
	return .spawn_player(player_id, spawn_position)


func _on_Player_death(player: CommonPlayer) -> void:
	._on_Player_death(player)
	player_lose_life(int(player.name))


func player_lose_life(player_id: int) -> void:
	if game_options.lives <= 0:
		# Lives are disabled so only knockback
		knockback_player(player_id)
		return
	player_lives[player_id] -= 1
	Network.Server.send_player_lost_life(player_id, player_lives[player_id])
	if player_lives[player_id] > 0:
		Logger.print(self, "Player %s lost a life - Remaining lives = %d" % [player_id, player_lives[player_id]])
		knockback_player(player_id)
	else:
		var death_time = time
		var player_info = player_list[player_id]
		Logger.print(self, "Player %s lost all their lives!" % [player_id])
		var death_entry = {
			"player_id": player_id,
			"time": death_time,
			"name": player_info.name,
			"colour": player_info.colour,
			"score": player_info.score,
		}
		# Push to front so first player to die shows up last
		players_died.push_front(death_entry)
		Network.Server.send_despawn_player(player_id)
		despawn_player(player_id)


func knockback_player(player_id: int) -> void:
	Network.Server.send_player_knockback(player_id)
	.knockback_player(player_id)


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
	var finish_time = time
	Logger.print(self, "Player %s finished: Place = %d Time = %f" % [player.name, place, finish_time])
	var player_id := int(player.name)
	var player_info = player_list[player_id]
	var finish_entry = {
		"player_id": player_id,
		"place": place,
		"time": finish_time,
		"name": player_info.name,
		"colour": player_info.colour,
		"score": player_info.score,
	}
	players_finished.push_back(finish_entry)
	Network.Server.send_player_finished_race(player_id, place, finish_time)
	._on_Player_finish(player)


func end_race() -> void:
	time_running = false
	var leaderboard := players_finished.duplicate()
	leaderboard.append_array(players_died)
	Network.Server.send_leaderboard(leaderboard)
	Logger.print(self, "Server Leaderboard: %s" % [leaderboard])
