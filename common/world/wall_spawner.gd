extends Node


class_name WallSpawner


export(PackedScene) var Wall


var game_rng: RandomNumberGenerator


# Wall vars
var height_range := 100
var gap_range_min := 130
var gap_range_max := 250
var wall_spacing := 400
var wall_spawn_range := 3000
var starting_wall_pos := 1500
var next_wall_pos := starting_wall_pos
var spawn_coin_chance := 0.5
var spawned_walls := []
var finish_line_x_pos := 0


func set_game_rng(rng: RandomNumberGenerator) -> void:
	game_rng = rng


func get_finish_line_x_position(goal: int) -> int:
	finish_line_x_pos = ((goal - 1) * wall_spacing) + starting_wall_pos
	return finish_line_x_pos


func reset_walls() -> void:
	for wall in spawned_walls:
		spawned_walls.erase(wall)
		wall.queue_free()
	var walls_to_spawn = round(wall_spawn_range / float(wall_spacing))
	for i in walls_to_spawn:
		spawn_wall()


func spawn_wall() -> void:
	if next_wall_pos >= finish_line_x_pos:
		# Don't spawn walls after the finish line
		return
	var inst = Wall.instance()
	inst.set_name("Wall" + str(next_wall_pos))
	# Use the game RNG to keep the levels deterministic
	var height := game_rng.randf_range(-height_range, height_range)
	var gap := game_rng.randf_range(gap_range_min, gap_range_max)
	var should_spawn_coin : bool = game_rng.randf() < spawn_coin_chance
	Logger.print(self, "Spawning wall - pos: %s height: %s - gap: %s" % [next_wall_pos, height, gap])
	inst.position = Vector2(next_wall_pos, height)
	inst.gap = gap
	if should_spawn_coin:
		inst.spawn_coin()
	next_wall_pos += wall_spacing
	call_deferred("add_child", inst)
	spawned_walls.append(inst)
