extends Node

tool

class_name LevelGenerator


export(Array) var Obstacles
export(Array) var ObstacleRandomWeights
export(PackedScene) var FinishLine


var game_rng: RandomNumberGenerator
# Controls how often frames are yielded, lower = smoother screen, but slower loading
var obstacles_per_frame := 25
var obstacle_spacing := 500
var spacing_increase := 10
var obstacle_start_pos := obstacle_spacing * 2
var max_obstacle_height_difference := 150
var max_height := 350
var generated_obstacles := []
var spawned_obstacles := {}
var next_obstacle_pos := Vector2(obstacle_start_pos, 0)
var finish_line: Node2D


signal progress_changed(percent)
signal level_ready


func _ready() -> void:
	if Engine.is_editor_hint():
		# Preview a level in the editor
		game_rng = RandomNumberGenerator.new()
		game_rng.randomize()
		generate(game_rng, 10)


func _notification(what):
	if what == NOTIFICATION_EXIT_TREE:
		# Stop memory leaks from generated objects
		clear_obstacles()


func generate(rng: RandomNumberGenerator, obstacles_to_generate: int) -> void:
	Logger.print(self, "Generating level with %d obstacles..." % obstacles_to_generate)
	game_rng = rng
	clear_obstacles()
	var start = OS.get_ticks_usec()
	# -1 to account for the finish line
	for i in obstacles_to_generate - 1:
		var obstacle := generate_obstacle()
		obstacle.set_name("%s_%d" % [obstacle.name, i])
		generated_obstacles.append(obstacle)
		next_obstacle_pos.x += obstacle.calculate_length() + obstacle_spacing
		obstacle_spacing += spacing_increase
		# Spread out the generation to stop the game freezing
		if (i % obstacles_per_frame) == 0:
			emit_signal("progress_changed", (float(i + 1) / obstacles_to_generate))
			yield(get_tree(), "idle_frame")
	# Finish line is always the final obstacle
	finish_line = FinishLine.instance()
	finish_line.position.x = next_obstacle_pos.x
	generated_obstacles.append(finish_line)
	var end = OS.get_ticks_usec()
	var generation_time = (end-start) / 1000
	Logger.print(self, "Obstacles generated in %dms!" % generation_time)
	emit_signal("progress_changed", 1.0)
	emit_signal("level_ready")


func clear_obstacles() -> void:
	for obst in generated_obstacles:
		obst.queue_free()
	generated_obstacles.clear()
	for obst in spawned_obstacles.values():
		obst.queue_free()
	spawned_obstacles.clear()


func generate_obstacle() -> Obstacle:
	assert(game_rng != null)
	assert(Obstacles.size() > 0)

	var obstacle = pick_random_weighted_obstacle()
	if obstacle.random_height:
		# # Only add or subtract from previous to ensure obstacles are still possible
		next_obstacle_pos.y += game_rng.randf_range(-max_obstacle_height_difference, max_obstacle_height_difference)
		next_obstacle_pos.y = clamp(next_obstacle_pos.y, -max_height, max_height)
	else:
		next_obstacle_pos.y = 0
	obstacle.position.x = next_obstacle_pos.x
	obstacle.height = next_obstacle_pos.y
	obstacle.generate(game_rng)
	return obstacle


func pick_random_weighted_obstacle() -> Obstacle:
	assert(Obstacles.size() == ObstacleRandomWeights.size())

	var sum_of_weights := 0
	for i in Obstacles.size():
		sum_of_weights += ObstacleRandomWeights[i]

	# Use the game RNG to keep the levels deterministic
	var rand = game_rng.randi_range(0, sum_of_weights-1)

	for i in Obstacles.size():
		if rand < ObstacleRandomWeights[i]:
			return Obstacles[i].instance()
		rand -= ObstacleRandomWeights[i]

	assert(false, "Failed to pick a random weighted choice")
	return null


func spawn_obstacle(obstacle_index: int) -> void:
	if obstacle_index >= generated_obstacles.size():
		push_error("Tried spawning obstacle %d but only %d were generated!" % [obstacle_index, generated_obstacles.size()])
		return
	if spawned_obstacles.has(obstacle_index):
		# Obstacle already spawned
		return
	var obstacle = generated_obstacles[obstacle_index]
	spawned_obstacles[obstacle_index] = obstacle
	Logger.print(self, "Spawning %s at %s", [obstacle.name, obstacle.position])
	# Defer because we can't spawn areas during a collision notification
	call_deferred("add_child", obstacle)


func despawn_obstacle(obstacle_index: int) -> void:
	if not spawned_obstacles.has(obstacle_index):
		push_error("Tried despawning obstacle %d but it hasn't been spawned!" % [obstacle_index])
		return
	var obstacle = spawned_obstacles[obstacle_index]
	Logger.print(self, "Despawning %s at %s", [obstacle.name, obstacle.position])
	# Only remove it as a child, so the object is still valid in generated_obstacles
	# Defer because it can't be removed during a signal
	call_deferred("remove_child", obstacle)
	var result = spawned_obstacles.erase(obstacle_index)
	assert(result)
