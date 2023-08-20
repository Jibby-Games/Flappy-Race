extends Obstacle

tool

const NAV_POLY_MARGIN := 32

export(PackedScene) var item_spawner := preload("res://client/world/spawners/item_spawner.tscn")
export(float) var radius := 400.0 setget set_radius
export(int) var coins := 12 setget set_coins

var spawned_coins := []


func _ready() -> void:
	generate_circle(radius, coins)


func generate_circle(new_radius: float, new_points: int) -> void:
	for coin in spawned_coins:
		coin.queue_free()
	spawned_coins.clear()
	var increment = (2 * PI) / new_points
	for i in new_points:
		var pos = polar2cartesian(new_radius, increment * i)
		var inst = item_spawner.instance()
		# Offset by radius so length calculations are correct
		inst.position = Vector2(new_radius, 0) + pos
		add_child(inst)
		spawned_coins.append(inst)


func do_generate(_game_rng: RandomNumberGenerator) -> void:
	# Nothing to generate
	pass


func generate_navigation_polygon() -> NavigationPolygon:
	var nav_poly := NavigationPolygon.new()
	# Outer and inner ring
	var increment = (2 * PI) / coins
	var outer_poly := []
	var inner_poly := []
	for i in coins:
		var pos = polar2cartesian(radius + NAV_POLY_MARGIN, increment * i)
		# Offset by radius so length calculations are correct
		outer_poly.append(Vector2(radius, 0) + pos)
		pos = polar2cartesian(radius - NAV_POLY_MARGIN, increment * i)
		inner_poly.append(Vector2(radius, 0) + pos)
	nav_poly.add_outline(outer_poly)
	nav_poly.add_outline(inner_poly)
	nav_poly.make_polygons_from_outlines()
	return nav_poly


func calculate_length() -> int:
	return $"%Checkpoint".position.x


func set_radius(value: float) -> void:
	radius = value
	generate_circle(radius, coins)


func set_coins(value: int) -> void:
	coins = value
	generate_circle(radius, coins)
