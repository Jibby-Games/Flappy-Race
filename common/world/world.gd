extends Node2D


class_name CommonWorld


export(PackedScene) var Wall
export(PackedScene) var Player
export(PackedScene) var FinishLine


# Wall vars
var height_range := 100
var gap_range_min := 130
var gap_range_max := 250
var wall_spacing := 400
var wall_spawn_range := 5000
var starting_wall_pos := 1500
var current_wall_pos := starting_wall_pos


var game_rng := RandomNumberGenerator.new()
var highest_score := 0
var goal := 100 setget set_goal
var finish_line_x_pos : int


var player_list := {}
var spawned_players := []
var spawned_walls := []


func _ready() -> void:
	Logger.print(self, "World ready!")


# Randomises the current game RNG seed and returns it
func randomize_game_seed() -> int:
	game_rng.randomize()
	Logger.print(self, "Generated random seed: %d" % [game_rng.seed])
	return game_rng.seed


# Sets the game RNG seed
func set_game_seed(new_seed: int) -> void:
	game_rng.seed = new_seed
	Logger.print(self, "Set game seed to: %d" % [new_seed])


func set_goal(new_goal: int) -> void:
	goal = new_goal
	Logger.print(self, "Set goal to: %d" % [new_goal])


func start_game(game_seed: int, new_goal: int, new_player_list: Dictionary) -> void:
	Logger.print(self, "Starting game with seed = %d, goal = %d and players: %s" %
		[game_seed, new_goal, new_player_list])
	set_game_seed(game_seed)
	set_goal(new_goal)
	self.player_list = new_player_list
	finish_line_x_pos = ((goal - 1) * wall_spacing) + starting_wall_pos
	spawn_finish_line(finish_line_x_pos)
	reset_walls()
	reset_players()


func reset_players() -> void:
	# Delete all existing players
	for player in spawned_players:
		spawned_players.erase(player)
		player.queue_free()
	Logger.print(self, "Spawning players in list: %s" % [player_list])
	for player_id in player_list:
		var player_entry = player_list[player_id]
		player_entry.score = 0
		player_entry.place = null
		# Don't spawn any spectators
		if player_entry.spectate == true:
			continue
		var player_body = spawn_player(player_id, Vector2.ZERO)
		player_entry["body"] = player_body
		spawned_players.append(player_body)


func spawn_finish_line(x_position: int) -> void:
	var finish_line = FinishLine.instance()
	finish_line.position = Vector2(x_position, 0)
	finish_line.connect("finish", self, "_on_Player_finish")
	add_child(finish_line)


func spawn_player(player_id: int, spawn_position: Vector2) -> Node2D:
	if not has_node(str(player_id)):
		Logger.print(self, "Spawning player %d" % [player_id])
		var player = Player.instance()
		player.connect("death", self, "_on_Player_death")
		player.connect("score_point", self, "_on_Player_score_point")
		player.name = str(player_id)
		player.position = spawn_position
		add_child(player)
		return player
	return null


func despawn_player(player_id: int) -> void:
	Logger.print(self, "Despawning player %d" % [player_id])
	var player = get_node_or_null(str(player_id))
	if player:
		spawned_players.erase(player)
		player.queue_free()
		if spawned_players.size() == 0:
			end_race()


#### Wall functions
func reset_walls() -> void:
	# Delete all existing walls
	for wall in spawned_walls:
		spawned_walls.erase(wall)
		wall.queue_free()
	var walls_to_spawn = round(wall_spawn_range / float(wall_spacing))
	for i in walls_to_spawn:
		spawn_wall()


func spawn_wall() -> void:
	if current_wall_pos >= finish_line_x_pos:
		# Don't spawn walls after the finish line
		return
	var inst = Wall.instance()
	inst.set_name("Wall" + str(current_wall_pos))
	# Use the game RNG to keep the levels deterministic
	var height = game_rng.randf_range(-height_range, height_range)
	var gap = game_rng.randf_range(gap_range_min, gap_range_max)
	Logger.print(self, "Spawning wall - pos: %s height: %s - gap: %s" % [current_wall_pos, height, gap])
	inst.position = Vector2(current_wall_pos, height)
	inst.gap = gap
	current_wall_pos += wall_spacing
	call_deferred("add_child", inst)
	spawned_walls.append(inst)


#### Player helper functions
func _on_Player_death(player: CommonPlayer) -> void:
	player.set_enable_movement(false)
	var player_id = int(player.name)
	despawn_player(player_id)


func _on_Player_score_point(player: CommonPlayer) -> void:
	var player_id = int(player.name)
	Logger.print(self, "Player %s scored a point!" % [player_id])
	player_list[player_id].score = player.score
	if player.score > highest_score:
		# Make the walls spawn as players progress
		highest_score = player.score
		spawn_wall()


func _on_Player_finish(player: CommonPlayer) -> void:
	var player_id = int(player.name)
	Logger.print(self, "Player %s crossed the finish line!" % player_id)
	despawn_player(player_id)


func end_race() -> void:
	Logger.print(self, "Race finished!")
