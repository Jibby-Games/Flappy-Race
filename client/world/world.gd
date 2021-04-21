extends Node2D


const WALL := preload("./wall/wall.tscn")
const PLAYER := preload("./player/player.tscn")


onready var Background := $Background
onready var HiScore := $UI/HighScore
onready var Score := $UI/Score
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

	WallSpawnTimer.wait_time = wall_spawn_time
	WallSpawnTimer.start()


func reset_game():
	# This works well enough for one player, but we actually want a less nuclear approach
	assert(get_tree().reload_current_scene() == OK)


#### Wall functions
func spawn_wall():
	var inst = WALL.instance()
	# Use the game RNG to keep the levels deterministic
	var height = Globals.game_rng.randf_range(-height_range, height_range)
	var gap = Globals.game_rng.randf_range(gap_range_min, gap_range_max)
	print("Spawning wall - height: ", height, " - gap: ", gap)
	inst.position = Vector2(get_viewport().size.x / 2 + 64, height)
	inst.gap = gap
	inst.speed = wall_speed
	call_deferred("add_child", inst)


func _on_WallSpawner_timeout():
	WallSpawnTimer.wait_time = wall_spawn_time * float(start_wall_speed) / wall_speed
	spawn_wall()


#### Player helper functions
func _on_Player_death(player):
	# See if we have a new PB
	if player.score > Globals.high_score:
		Globals.set_high_score(player.score)
		HiScore.text = str(player.score)

	# Tell the engine it can lose the player
	player.queue_free()

	reset_game()


func _on_Player_score_point(player):
	# Actual incrementing is handled on the player object
	increase_difficulty()
	Score.text = str(player.score)


#### World functions
func increase_difficulty():
	wall_speed += speed_up
	# Speed up the background
	# TODO: this causes jerky stutter. Needs fixing.
	# Background.material.set_shader_param('scroll_speed', wall_speed*parallax)
	for wall in get_tree().get_nodes_in_group("walls"):
		wall.speed = wall_speed


func _on_BGMusic_finished():
	$BGMusic.play()
