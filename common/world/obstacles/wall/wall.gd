extends Obstacle

export(PackedScene) var item_spawner

var gap_range_min := 130
var gap_range_max := 250
var spawn_coin_chance := 0.5
# Needed so there's no impossible walls
var extra_spacing := 150


func do_generate(game_rng: RandomNumberGenerator, spawn_items: bool) -> void:
	var gap: float = game_rng.randf_range(gap_range_min, gap_range_max)
	var should_spawn_coin: bool = game_rng.randf() < spawn_coin_chance if spawn_items else false
	# Logger.print(self, "Generating wall - pos: %s height: %s - gap: %s" % [global_position, height, gap])
	$Wall.position.y = height
	set_gap(gap)
	if should_spawn_coin:
		var spawner = item_spawner.instance()
		spawner.position.x = $Wall/UpperCollider.shape.extents.x
		$Wall.add_child(spawner)
	# So spawn point lines up with wall gap
	$"%Checkpoint".position.y = height


func calculate_length() -> int:
	return $"%Checkpoint".position.x + extra_spacing


func set_gap(size: float) -> void:
	var rect_collider_pos = $Wall/UpperCollider.shape.extents.y + (size / 2)
	$Wall/LowerCollider.position.y = rect_collider_pos
	$Wall/UpperCollider.position.y = -rect_collider_pos


func generate_navigation_polygon() -> NavigationPolygon:
	var nav_poly := NavigationPolygon.new()
	nav_poly.add_outline(get_boundary_poly())
	nav_poly.add_outline(get_poly($Wall/UpperCollider))
	nav_poly.add_outline(get_poly($Wall/LowerCollider))
	nav_poly.make_polygons_from_outlines()
	return nav_poly
