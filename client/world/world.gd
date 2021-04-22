extends Node2D


const WALL := preload("./wall/wall.tscn")
const PLAYER := preload("./player/player.tscn")


onready var Background := $Background
onready var HiScore := $Camera2D/UI/HighScore
onready var Score := $Camera2D/UI/Score
onready var WallSpawnTimer := $WallSpawnTimer


# Public vars
var height_range := 100
var gap_range_min := 130
var gap_range_max := 250
var wall_spawn_time := 2.5
var start_wall_speed := 4.0
var wall_speed := start_wall_speed
var speed_up := 0.1
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
	start_game()


func start_game() -> void:
	Globals.randomize_game_seed()
	var player = PLAYER.instance()
	player.connect("death", self, "_on_Player_death")
	player.connect("score_point", self, "_on_Player_score_point")
	add_child(player)
	wall_speed = start_wall_speed
	WallSpawnTimer.wait_time = wall_spawn_time
	WallSpawnTimer.start()


func reset_game() -> void:
	Network.Client.change_scene("res://client/world/world.tscn")


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
		Globals.set_high_score(player.score)
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
