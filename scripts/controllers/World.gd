extends Node2D

var Wall = preload("res://scenes/Wall.tscn")
var height_range = 100
var gap_range_min = 130
var gap_range_max = 250

onready var Background = $Background
onready var HiScore = $UI/HighScore
onready var Score = $UI/Score

var high_score_fname = "user://highscore.save"

onready var WallSpawnTimer = $WallSpawnTimer

var wall_spawn_time = 2.5
var start_wall_speed = 4.0
var wall_speed = start_wall_speed
var speed_up = 0.1
var scroll_speed = 0.1
var bob_speed = 1.0
var bob_amplitude = 0.01


func _ready():
	# Setup gubbins
	HiScore.text = str(load_score())
	
	# Set the wallpaper motion
	Background.material.set_shader_param('scroll_speed', scroll_speed)
	Background.material.set_shader_param('bob_speed', bob_speed)
	Background.material.set_shader_param('bob_amplitude', bob_amplitude)
		
	WallSpawnTimer.wait_time = wall_spawn_time
	WallSpawnTimer.start()
	
	# Give all the players an ID
	Net.set_ids()
	# and create a player sprite for each.
	create_players()
	# Then, create my own lil guy
	$Player.initialise(Net.net_id)

func create_players():
	for id in Net.peer_ids:
		create_player(id)

func create_player(id):
	var p = preload("res://scenes/Player.tscn").instance()
	add_child(p)
	p.initialise(id)

func reset_game():
	# This works well enough for one player, but we actually want a less nuclear approach
	var _ok = get_tree().reload_current_scene()


#### Wall functions
func spawn_wall():
	var inst = Wall.instance()
	inst.position = Vector2(get_viewport().size.x / 2 + 64, rand_range(-height_range, height_range))
	inst.gap = rand_range(gap_range_min, gap_range_max)
	inst.speed = wall_speed
	call_deferred("add_child", inst)

func _on_WallSpawner_timeout():
	WallSpawnTimer.wait_time = wall_spawn_time * float(start_wall_speed) / wall_speed
	spawn_wall()


#### Player helper functions
func _on_Player_death(player):
	# See if we have a new PB
	if player.score > int(HiScore.text):
		save_score(player.score)
		HiScore.text = str(player.score)
	
	# Tell the engine it can lose the player
	player.queue_free()
	
	reset_game()

func _on_Player_score_point(player):
	# Actual incrimenting is handled on the player object
	increase_difficulty()
	Score.text = str(player.score)


#### World functions
func increase_difficulty():
	wall_speed += speed_up
	# Speed up the background
	# Background.material.set_shader_param('scroll_speed', wall_speed*parallax)
	for wall in get_tree().get_nodes_in_group("walls"):
		wall.speed = wall_speed

func load_score():
	var high_score = 0
	
	var saved = File.new()
	if not saved.file_exists(high_score_fname):
		return high_score
	
	saved.open(high_score_fname, File.READ)
	while saved.get_position() < saved.get_len():
		var data = parse_json(saved.get_line())
		high_score = int(data['highscore'])
	saved.close()
	
	return high_score

func save_score(score):
	var saved = File.new()
	saved.open(high_score_fname, File.WRITE)
	
	# We will store as a JSON object. Overkill for a single integer, but should 
	# be easy to scale out.
	var score_dict = {"highscore": score}
	saved.store_line(to_json(score_dict))
	saved.close()
