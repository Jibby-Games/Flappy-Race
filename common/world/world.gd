extends Node2D


class_name CommonWorld


export(PackedScene) var Wall
export(PackedScene) var Player


# Wall vars
var height_range := 100
var gap_range_min := 130
var gap_range_max := 250
var wall_spacing := 400
var wall_spawn_range := 1000
var current_wall_pos := wall_spawn_range


var game_rng := RandomNumberGenerator.new()
var highest_score := 0


var player_list := {}
var spawned_players := []
var spawned_walls := []


func _ready() -> void:
	print("[%s] World ready!" % [get_path().get_name(1)])


# Randomises the current game RNG seed and returns it
func randomize_game_seed() -> int:
	game_rng.randomize()
	print("[%s] Generated random seed: %d" % [get_path().get_name(1), game_rng.seed])
	return game_rng.seed


# Sets the game RNG seed
func set_game_seed(new_seed: int) -> void:
	game_rng.seed = new_seed
	print("[%s] Set game seed to: %d" % [get_path().get_name(1), new_seed])


func start_game(game_seed: int, new_player_list: Dictionary) -> void:
	print("[%s] Starting game with seed %d and players: %s" %
		[get_path().get_name(1), game_seed, new_player_list])
	set_game_seed(game_seed)
	self.player_list = new_player_list
	reset_walls()
	reset_players()


func reset_players() -> void:
	# Delete all existing players
	for player in spawned_players:
		spawned_players.erase(player)
		player.queue_free()
	print("[%s] Spawning players in list: %s" % [get_path().get_name(1), player_list])
	for player_id in player_list:
		# Don't spawn any spectators
		if player_list[player_id].spectate == true:
			continue
		var player = spawn_player(player_id, Vector2.ZERO)
		player_list[player_id]["body"] = player
		spawned_players.append(player)


func spawn_player(player_id: int, spawn_position: Vector2) -> Node2D:
	if not has_node(str(player_id)):
		print("[%s] Spawning player %d" % [get_path().get_name(1), player_id])
		var player = Player.instance()
		player.connect("death", self, "_on_Player_death")
		player.connect("score_point", self, "_on_Player_score_point")
		player.name = str(player_id)
		player.position = spawn_position
		add_child(player)
		return player
	return null


func despawn_player(player_id: int) -> void:
	print("[%s] Despawning player %d" % [get_path().get_name(1), player_id])
#	yield(get_tree().create_timer(0.2), "timeout")
	var player = get_node_or_null(str(player_id))
	if player:
		spawned_players.erase(player)
		player.queue_free()


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
	var inst = Wall.instance()
	inst.set_name("Wall" + str(current_wall_pos))
	# Use the game RNG to keep the levels deterministic
	var height = game_rng.randf_range(-height_range, height_range)
	var gap = game_rng.randf_range(gap_range_min, gap_range_max)
	print("[%s] Spawning wall - pos: %s height: %s - gap: %s" % [get_path().get_name(1), current_wall_pos, height, gap])
	inst.position = Vector2(current_wall_pos, height)
	inst.gap = gap
	current_wall_pos += wall_spacing
	call_deferred("add_child", inst)
	spawned_walls.append(inst)


#### Player helper functions
func _on_Player_death(player: Node2D) -> void:
	player.set_enable_movement(false)
	despawn_player(int(player.name))


func _on_Player_score_point(player) -> void:
	print("[%s] Player %s scored a point!" % [get_path().get_name(1), player.name])
	if player.score > highest_score:
		# Make the walls spawn as players progress
		highest_score = player.score
		spawn_wall()
