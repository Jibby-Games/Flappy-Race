extends Obstacle


export(PackedScene) var CoinSpawner


var height_range := 100
var gap_range_min := 130
var gap_range_max := 250
var spawn_coin_chance := 0.5
# Needed so there's no impossible walls
var extra_spacing := 150


func do_generate(game_rng) -> void:
	var height: float = game_rng.randf_range(-height_range, height_range)
	var gap: float = game_rng.randf_range(gap_range_min, gap_range_max)
	var should_spawn_coin: bool = game_rng.randf() < spawn_coin_chance
	# Logger.print(self, "Generating wall - pos: %s height: %s - gap: %s" % [global_position, height, gap])
	$Wall.position.y = height
	set_gap(gap)
	if should_spawn_coin:
		var spawner = CoinSpawner.instance()
		$Wall.add_child(spawner)
	# So spawn point lines up with wall gap
	$"%Checkpoint".position.y = height


func calculate_length() -> int:
	return $"%Checkpoint".position.x + extra_spacing


func set_gap(size: float) -> void:
	var rect_collider_pos = $Wall/UpperCollider.shape.extents.y + (size / 2)
	$Wall/LowerCollider.position.y = rect_collider_pos
	$Wall/UpperCollider.position.y = -rect_collider_pos
