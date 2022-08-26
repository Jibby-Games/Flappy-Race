extends Node

tool

class_name LevelGenerator


export(Array) var Obstacles
export(PackedScene) var FinishLine


var game_rng: RandomNumberGenerator
var obstacle_spacing := 400
var obstacle_start_pos := 1500
var next_obstacle_pos := obstacle_start_pos
var intial_obstacle_amount := 10
var generated_obstacles := []
var spawned_obstacles := []
var finish_line: Node2D


signal level_ready


func _ready() -> void:
	if Engine.is_editor_hint():
		# Preview a level in the editor
		game_rng = RandomNumberGenerator.new()
		generate(game_rng, 10)


func generate(rng: RandomNumberGenerator, obstacles_to_spawn: int) -> void:
	Logger.print(self, "Generating level with %d obstacles..." % obstacles_to_spawn)
	game_rng = rng
	clear_obstacles()
	var start = OS.get_ticks_usec()
	for i in obstacles_to_spawn:
		generate_obstacle()
	var end = OS.get_ticks_usec()
	var generation_time = (end-start) / 1000
	Logger.print(self, "Obstacles generated in %dms!" % generation_time)
	# In case there are fewer than the initial amount
	var spawn_amount := min(obstacles_to_spawn, intial_obstacle_amount)
	for i in spawn_amount:
		spawn_obstacle()
	spawn_finish_line()
	emit_signal("level_ready")


func clear_obstacles() -> void:
	for obst in generated_obstacles:
		obst.queue_free()
	generated_obstacles.clear()
	for obst in spawned_obstacles:
		obst.queue_free()
	spawned_obstacles.clear()


func generate_obstacle() -> void:
	assert(game_rng != null)
	assert(Obstacles.size() > 0)
	# Use the game RNG to keep the levels deterministic
	var index = game_rng.randi_range(0, Obstacles.size() - 1)
	var obstacle = Obstacles[index].instance()
	obstacle.set_name("%s%d" % [obstacle.name, next_obstacle_pos])
	obstacle.position.x = next_obstacle_pos
	obstacle.generate(game_rng)
	generated_obstacles.append(obstacle)
	next_obstacle_pos += obstacle.calculate_length() + obstacle_spacing


func spawn_obstacle() -> void:
	if generated_obstacles.size() <= 0:
		Logger.print(self, "Tried calling spawn_obstacle but all obstacles have been spawned!")
		return
	var obstacle = generated_obstacles.pop_front()
	spawned_obstacles.append(obstacle)
	# Defer because we can't spawn areas during a collision notification
	call_deferred("add_child", obstacle)


func spawn_finish_line() -> void:
	finish_line = FinishLine.instance()
	finish_line.position.x = next_obstacle_pos
	add_child(finish_line)
