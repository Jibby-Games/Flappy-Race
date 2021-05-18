extends Node2D


class_name CommonWorld


export(PackedScene) var Wall
export(PackedScene) var Player


onready var WallSpawnTimer := $WallSpawnTimer


# Wall vars
var height_range := 100
var gap_range_min := 130
var gap_range_max := 250
var wall_spawn_time := 2.5
var start_wall_speed := 4.0
var wall_speed := start_wall_speed
var speed_up := 0.1


func start_game(game_seed) -> void:
	print("[COM] Starting game with seed %s" % game_seed)
	Globals.set_game_seed(game_seed)
	for player in multiplayer.get_network_connected_peers():
		# Don't spawn the server as a player
		if player != 1:
			spawn_player(player, Vector2.ZERO)
	reset_walls()


func spawn_player(player_id, spawn_position, is_controllable = false):
	if not has_node(str(player_id)):
		print(get_path(), ": Spawning player ", player_id)
		var player = Player.instance()
		player.connect("death", self, "_on_Player_death")
		player.connect("score_point", self, "_on_Player_score_point")
		player.name = str(player_id)
		player.position = spawn_position
		if is_controllable:
			player.enable_control()
		add_child(player)


func despawn_player(player_id):
	print("[COM] Despawning player %s" % player_id)
	yield(get_tree().create_timer(0.2), "timeout")
	var player = get_node(str(player_id))
	if player:
		player.queue_free()


#### Wall functions
func reset_walls():
	wall_speed = start_wall_speed
	$WallSpawnTimer.wait_time = wall_spawn_time
	$WallSpawnTimer.start()


func spawn_wall() -> void:
	var inst = Wall.instance()
	# Use the game RNG to keep the levels deterministic
	var height = Globals.game_rng.randf_range(-height_range, height_range)
	var gap = Globals.game_rng.randf_range(gap_range_min, gap_range_max)
	print("[WORLD]: Spawning wall - height: ", height, " - gap: ", gap)
	inst.position = Vector2(get_viewport().size.x / 2 + 64, height)
	inst.gap = gap
	inst.speed = wall_speed
	call_deferred("add_child", inst)


func _on_WallSpawner_timeout() -> void:
	$WallSpawnTimer.wait_time = wall_spawn_time * float(start_wall_speed) / wall_speed
	spawn_wall()


#### Player helper functions
func _on_Player_death(player) -> void:
	# Tell the engine it can lose the player
	player.queue_free()
	$WallSpawnTimer.stop()


func _on_Player_score_point(_player) -> void:
	increase_difficulty()


#### World functions
func increase_difficulty() -> void:
	wall_speed += speed_up
	for wall in get_tree().get_nodes_in_group("walls"):
		wall.speed = wall_speed
