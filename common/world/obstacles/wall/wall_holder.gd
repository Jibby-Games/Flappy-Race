extends Obstacle


var height_range := 100
var gap_range_min := 130
var gap_range_max := 250
var spawn_coin_chance := 0.5


func do_generate(game_rng) -> void:
	var inst := $Wall
	var height: float = game_rng.randf_range(-height_range, height_range)
	var gap: float = game_rng.randf_range(gap_range_min, gap_range_max)
	var should_spawn_coin : bool = game_rng.randf() < spawn_coin_chance
	# Logger.print(self, "Generating wall - pos: %s height: %s - gap: %s" % [global_position, height, gap])
	inst.position.y = height
	inst.set_gap(gap)
	if should_spawn_coin:
		inst.spawn_coin()
	# So spawn point lines up with wall gap
	$"%Checkpoint".position.y = height


func calculate_length() -> int:
	return $Wall.position.x + $"%Checkpoint".position.x
