extends Node2D


const WALL := preload("./wall/wall.tscn")
const PLAYER := preload("./player/player.tscn")
const INTERPOLATION_OFFSET = 100

onready var Background := $Background
onready var HiScore := $Camera2D/UI/HighScore
onready var Score := $Camera2D/UI/Score
onready var WallSpawnTimer := $WallSpawnTimer


# World state vars
var last_world_state := 0
var world_state_buffer := []

# Wall vars
var height_range := 100
var gap_range_min := 130
var gap_range_max := 250
var wall_spawn_time := 2.5
var start_wall_speed := 4.0
var wall_speed := start_wall_speed
var speed_up := 0.1

# Background vars
var scroll_speed := 0.1
var bob_speed := 1.0
var bob_amplitude := 0.01

func _ready():
	# Setup gubbins
	HiScore.text = str(Globals.high_score)

	# Set the wallpaper motion
	Background.material.set_shader_param('scroll_speed', scroll_speed)
	Background.material.set_shader_param('bob_speed', bob_speed)
	Background.material.set_shader_param('bob_amplitude', bob_amplitude)


func _physics_process(_delta):
	var render_time = OS.get_system_time_msecs() - INTERPOLATION_OFFSET
	if world_state_buffer.size() > 1:
		while world_state_buffer.size() > 2 and render_time > world_state_buffer[1].T:
			world_state_buffer.remove(0)
		var interpolation_factor = float(render_time - world_state_buffer[0]["T"]) / float(world_state_buffer[1]["T"] - world_state_buffer[0]["T"])
		for player in world_state_buffer[1].keys():
			if str(player) == "T":
				continue
			if player == multiplayer.get_network_unique_id():
				continue
			if not world_state_buffer[0].has(player):
				# Connecting player won't be available in past world_state yet
				continue
			if has_node(str(player)):
				# Use the position between past and future world_states
				var new_position = lerp(
					world_state_buffer[0][player]["P"],
					world_state_buffer[1][player]["P"],
					interpolation_factor
				)
				get_node(str(player)).move_player(new_position)
			else:
				spawn_player(player, world_state_buffer[1][player]["P"])


func update_world_state(world_state) -> void:
	if world_state["T"] > last_world_state:
		last_world_state = world_state["T"]
		world_state_buffer.append(world_state)


func start_game(game_seed = null) -> void:
	print("[CNT] Starting game with seed %s" % game_seed)
	if game_seed:
		Globals.set_game_seed(game_seed)
	else:
		var _seed = Globals.randomize_game_seed()
	spawn_player(multiplayer.get_network_unique_id(), Vector2(0, 0), true)
	for player in multiplayer.get_network_connected_peers():
		# Don't spawn the server as a player
		if player != 1:
			spawn_player(player, Vector2(0, 0))
	reset_walls()


func spawn_player(player_id, spawn_position, is_master = false):
	if not has_node(str(player_id)):
		print("[CNT] Spawning player %s" % player_id)
		var player = PLAYER.instance()
		player.connect("death", self, "_on_Player_death")
		player.connect("score_point", self, "_on_Player_score_point")
		player.name = str(player_id)
		player.position = spawn_position
		player.is_master = is_master
		add_child(player)


func despawn_player(player_id):
	print("[CNT] Despawning player %s" % player_id)
	var player = get_node(str(player_id))
	if player:
		player.queue_free()


func reset_walls():
	wall_speed = start_wall_speed
	WallSpawnTimer.wait_time = wall_spawn_time
	WallSpawnTimer.start()


func reset_game() -> void:
	Network.Client.request_start_game()


#### Wall functions
func spawn_wall() -> void:
	var inst = WALL.instance()
	# Use the game RNG to keep the levels deterministic
	var height = Globals.game_rng.randf_range(-height_range, height_range)
	var gap = Globals.game_rng.randf_range(gap_range_min, gap_range_max)
	print("[WORLD]: Spawning wall - height: ", height, " - gap: ", gap)
	inst.position = Vector2(get_viewport().size.x / 2 + 64, height)
	inst.gap = gap
	inst.speed = wall_speed
	call_deferred("add_child", inst)


func _on_WallSpawner_timeout() -> void:
	WallSpawnTimer.wait_time = wall_spawn_time * float(start_wall_speed) / wall_speed
	spawn_wall()


#### Player helper functions
func _on_Player_death(player) -> void:
	# See if we have a new PB
	if player.score > Globals.high_score:
		Globals.save_high_score(player.score)
		HiScore.text = str(player.score)

	# Tell the engine it can lose the player
	player.queue_free()
	show_game_over()


func show_game_over() -> void:
	WallSpawnTimer.stop()
	$Camera2D/UI/GameOver.show()


func _on_Player_score_point(player) -> void:
	# Actual incrementing is handled on the player object
	increase_difficulty()
	Score.text = str(player.score)


#### World functions
func increase_difficulty() -> void:
	wall_speed += speed_up
	# Speed up the background
	# TODO: this causes jerky stutter. Needs fixing.
	# Background.material.set_shader_param('scroll_speed', wall_speed*parallax)
	for wall in get_tree().get_nodes_in_group("walls"):
		wall.speed = wall_speed


func _on_BGMusic_finished() -> void:
	$BGMusic.play()


func _on_RestartButton_pressed() -> void:
	reset_game()
