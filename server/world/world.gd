extends CommonWorld

# The standard deviation for bot difficulty generation
# Low values seem to give a good spread from testing
const BOT_DIFFICULTY_DEVIATION := 0.08

export(PackedScene) var BotController = preload("res://common/world/bot/bot_controller.tscn")

var ready_callback: String
var players_not_ready: Array
var next_place := 1
var player_lives := {}
var players_died := []
var players_finished := []
var bot_controllers := []

# Timing
var time_running := false
var time := 0.0


func _ready() -> void:
	Globals.server_world = self
	wait_for_all_players_ready_then("setup_and_start_game")


func _process(delta: float) -> void:
	if time_running:
		time += delta


func wait_for_all_players_ready_then(callback: String, include_server: bool = false) -> void:
	assert(not callback.empty())
	ready_callback = callback
	Logger.print(self, "Waiting for all players to be ready, then calling: %s" % ready_callback)
	players_not_ready.clear()
	if include_server:
		players_not_ready.append(Network.Server.SERVER_ID)
	for player_id in multiplayer.get_network_connected_peers():
		players_not_ready.append(player_id)


func set_player_ready(player_id: int) -> void:
	if ready_callback.empty():
		# Not waiting for anything, player could have late joined
		return
	players_not_ready.erase(player_id)
	if players_not_ready.size() == 0:
		Logger.print(self, "All players are ready! Calling: %s" % ready_callback)
		# Callback must be cached and cleared before call or the callback could
		# try to start another wait_for_all_players_ready_then which would get cleared
		var callback := ready_callback
		ready_callback = ""
		call(callback)


func setup_and_start_game() -> void:
	Logger.print(self, "Setting up and starting game!")
	var game_seed = randomize_game_seed()
	Network.Server.send_game_started(game_seed)
	start_game(game_seed, Network.Server.game_options, Network.Server.player_list)


func start_game(game_seed: int, new_game_options: Dictionary, new_player_list: Dictionary) -> void:
	wait_for_all_players_ready_then("start_countdown", true)
	.start_game(game_seed, new_game_options, new_player_list)
	if not level_generator.level_ready:
		# Level generator could be finished before returning to this function
		yield(level_generator, "level_ready")
	# Show that the server is ready
	set_player_ready(Network.Server.SERVER_ID)


func start_countdown() -> void:
	.start_countdown()
	Network.Server.send_start_countdown()
	yield(get_tree().create_timer(3), "timeout")
	time_running = true
	# Normally players don't move on the serverside so bots need to be started
	for bot in bot_controllers:
		bot.player.start()


func reset_players() -> void:
	if game_options.lives > 0:
		player_lives.clear()
	bot_controllers.clear()
	.reset_players()
	if not bot_controllers.empty():
		generate_bot_difficulties(game_options.difficulty, bot_controllers)


# Randomise the difficulty of all bots around a set difficulty value
# Should use the Difficulty enum
func generate_bot_difficulties(difficulty: int, bots: Array) -> void:
	if not difficulty in Difficulty.values():
		push_error("Difficulty value not in Difficulty enum! Value: %d" % difficulty)
		return
	if bots.empty():
		push_error("Can't generate difficulties for empty bot list!")
		return
	Logger.print(self, "Generating bot difficulties...")
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	# Should increase in increments so 0-4 turns into 0.0, 0.25, 0.5, 0.75, 1.0
	var difficulty_coeff: float = difficulty * 0.25
	for bot in bots:
		# Use a normal distribution with a low deviation to get a good spread of bot difficulties
		var value := rng.randfn(difficulty_coeff, BOT_DIFFICULTY_DEVIATION)
		bot.set_difficulty(clamp(value, 0.0, 1.0))


func spawn_player(player_id: int, spawn_position: Vector2, is_bot: bool) -> Node2D:
	if game_options.lives > 0:
		player_lives[player_id] = game_options.lives
	var player_body := .spawn_player(player_id, spawn_position, is_bot)
	if is_bot:
		var bot_controller: BotController = BotController.instance()
		bot_controller.player = player_body
		bot_controller.target_pos = level_generator.finish_line.position
		player_body.add_child(bot_controller)
		bot_controllers.append(bot_controller)
	return player_body


func despawn_player(player_id: int) -> void:
	var player = get_node_or_null(str(player_id))
	if player:
		chunk_tracker.remove_player(player_id)
	.despawn_player(player_id)


func _on_Player_death(player: CommonPlayer) -> void:
	._on_Player_death(player)
	if game_options.lives > 0:
		var player_id := int(player.name)
		player_lose_life(player_id)
		if not player.is_bot:
			Network.Server.send_player_lost_life(player_id, player_lives[player_id])


func player_lose_life(player_id: int) -> void:
	player_lives[player_id] -= 1
	if player_lives[player_id] > 0:
		Logger.print(
			self,
			"Player %s lost a life - Remaining lives = %d" % [player_id, player_lives[player_id]]
		)
	else:
		var death_time = time
		var player_info = player_list[player_id]
		Logger.print(self, "Player %s lost all their lives!" % [player_id])
		var death_entry = create_leaderboard_entry(player_id, death_time, player_info)
		# Push to front so first player to die shows up last
		players_died.push_front(death_entry)
		Network.Server.send_despawn_player(player_id)
		despawn_player(player_id)


func _on_Player_score_changed(player: CommonPlayer) -> void:
	._on_Player_score_changed(player)
	var player_id = int(player.name)
	player_list[player_id].score = player.score


func _on_Player_finish(player: CommonPlayer) -> void:
	# Store the place immediately in case the funciton gets called multiple times while it's running
	var place := next_place
	next_place += 1
	var finish_time = time
	Logger.print(
		self, "Player %s finished: Place = %d Time = %f" % [player.name, place, finish_time]
	)
	var player_id := int(player.name)
	var player_info = player_list[player_id]
	var finish_entry = create_leaderboard_entry(player_id, finish_time, player_info)
	finish_entry["place"] = place
	players_finished.push_back(finish_entry)
	Network.Server.send_player_finished_race(player_id, place, finish_time)
	._on_Player_finish(player)


func end_race() -> void:
	.end_race()
	time_running = false
	var leaderboard := players_finished.duplicate()
	leaderboard.append_array(players_died)
	Network.Server.send_leaderboard(leaderboard)
	Logger.print(self, "Server Leaderboard: %s" % [leaderboard])


func create_leaderboard_entry(player_id: int, finish_time: float, player_info: Dictionary) -> Dictionary:
	return {
		"player_id": player_id,
		"time": finish_time,
		"name": player_info.name,
		"colour": player_info.colour,
		"progress": float(player_info.score) / game_options.goal,
	}
