extends Node2D

var Wall = preload("res://scenes/Wall.tscn")
var height_range = 100
var gap_range_min = 100
var gap_range_max = 250

onready var Score = $UI/Score
var score = 0

onready var WallSpawnTimer = $WallSpawnTimer

var wall_spawn_time = 2.5
var start_wall_speed = 2
var wall_speed = start_wall_speed
var speed_up = 0.1

func _ready():
	WallSpawnTimer.wait_time = wall_spawn_time
	WallSpawnTimer.start()

func spawn_wall():
	var inst = Wall.instance()
	inst.position = Vector2(get_viewport().size.x / 2 + 64, rand_range(-height_range, height_range))
	inst.gap = rand_range(gap_range_min, gap_range_max)
	inst.speed = wall_speed
	call_deferred("add_child", inst)


func _on_WallSpawner_timeout():
	WallSpawnTimer.wait_time = wall_spawn_time * float(start_wall_speed) / wall_speed
	spawn_wall()


func _on_Player_death():
	print("Player died!")
	var _ok = get_tree().reload_current_scene()


func _on_Player_score_point(_player):
	score += 1
	if score % 2 == 0:
		increase_difficulty()
	Score.text = str(score)
	print("Score = ", score)


func increase_difficulty():
	wall_speed += speed_up
	for wall in get_tree().get_nodes_in_group("walls"):
		wall.speed = wall_speed
	print("Increasing difficulty: wall_speed = ", wall_speed)
