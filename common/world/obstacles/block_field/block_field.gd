extends Obstacle

tool

const BLOCK_SIZE := 64
const MIN_BLOCK_DISTANCE := 180
const NAV_POLY_MARGIN := BLOCK_SIZE * 1.5

export(PackedScene) var Block
export(PackedScene) var CoinSpawner
export(float) var block_density := 0.05 setget set_block_density
export(int) var field_length := 900 setget set_field_length
export(int) var field_height := 1016 setget set_field_height
export(int) var checkpoint_distance := 128 setget set_checkpoint_distance
export(int) var max_coins := 3 setget set_max_coins
# This is just to regenerate the editor preview
export(bool) var generate_blocks := false setget _do_generate_blocks

var blocks := []
var coins := []
var points := []


func _ready() -> void:
	if Engine.is_editor_hint():
		_do_generate_blocks()


func do_generate(game_rng: RandomNumberGenerator) -> void:
	for block in blocks:
		block.queue_free()
	blocks.clear()
	for coin in coins:
		coin.queue_free()
	coins.clear()
	points.clear()
	var blocks_to_spawn: int = int(
		field_length * field_height * block_density / (BLOCK_SIZE * BLOCK_SIZE)
	)
	var coins_to_spawn: int = game_rng.randi_range(0, max_coins)
	for i in blocks_to_spawn:
		var overlap := true
		var iters := 0
		var pos: Vector2
		var failed_blocks := 0
		# Add an iteration limit so we don't get stuck in an infinite loop
		while overlap == true and iters < 100:
			pos = get_random_point_in_field(game_rng)
			overlap = false
			for point in points:
				if point.distance_to(pos) < MIN_BLOCK_DISTANCE:
					# Too close to other objects, try again!
					overlap = true
					iters += 1
					break
		if overlap == true:
			# Couldn't place block
			print("Unable to place block!")
			failed_blocks += 1
			continue
		if failed_blocks > 0:
			print("Failed to place %d blocks" % failed_blocks)
		var inst: Node2D
		if coins.size() < coins_to_spawn:
			inst = CoinSpawner.instance()
			coins.append(inst)
		else:
			inst = Block.instance()
			blocks.append(inst)
		inst.position = pos
		add_child(inst)
		points.append(pos)
	$"%Checkpoint".position.x = field_length + checkpoint_distance
	$"%PointArea".position.x = $"%Checkpoint".position.x


func get_random_point_in_field(game_rng: RandomNumberGenerator) -> Vector2:
	return Vector2(game_rng.randf() * field_length, (game_rng.randf() - 0.5) * field_height)


func calculate_length() -> int:
	return field_length + checkpoint_distance


func set_block_density(value: float) -> void:
	block_density = value
	if Engine.is_editor_hint():
		_do_generate_blocks()


func set_field_length(value: int) -> void:
	field_length = value
	if Engine.is_editor_hint():
		_do_generate_blocks()


func set_field_height(value: int) -> void:
	field_height = value
	if Engine.is_editor_hint():
		_do_generate_blocks()


func set_checkpoint_distance(value: int) -> void:
	checkpoint_distance = value
	if Engine.is_editor_hint():
		_do_generate_blocks()


func set_max_coins(value: int) -> void:
	max_coins = value
	if Engine.is_editor_hint():
		_do_generate_blocks()


func _do_generate_blocks(_value: bool = false) -> void:
	# Create RNG for testing purposes
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	generate(rng)


# NAV DEBUG
# var debug_draw_polys := []
# func _draw() -> void:
# 	for poly in debug_draw_polys:
# 		draw_colored_polygon(poly, Color.red)


func generate_navigation_polygon() -> NavigationPolygon:
	# Don't generate in editor
	if Engine.is_editor_hint():
		return null
	var nav_poly := NavigationPolygon.new()
	nav_poly.add_outline(get_boundary_poly())

	# Advanced nav poly:

	# Check the vertices of each block and see if they intersects with any other
	# merged polygons and merge their polygons if they do too.
	var merged_polys := []
	for block in blocks:
		var current_poly := get_square_nav_polygon(block.position)
		var poly_to_merge := current_poly
		var merged := false
		var to_remove := {}
		for j in merged_polys.size():
			# Check if any of the vertices are inside existing merged polygons
			var check_poly = merged_polys[j]
			for vert in current_poly:
				if Geometry.is_point_in_polygon(vert, check_poly):
					# Merge the poly and mark the old one to be removed
					var new_poly := Geometry.merge_polygons_2d(poly_to_merge, check_poly)
					to_remove[j] = 1
					# Have to switch out the poly as it could be merged multiple times
					poly_to_merge = new_poly[0]
					merged = true
		if merged:
			# Remove any previously merged polys as our current one will contain them
			# Can't remove indexes in place as there could be duplicates and order will get messed up
			var new_polys := []
			for i in merged_polys.size():
				if not to_remove.has(i):
					new_polys.append(merged_polys[i])
			merged_polys = new_polys
		merged_polys.append(poly_to_merge)

	for poly in merged_polys:
		nav_poly.add_outline(poly)

	# for i in range(1, nav_poly.get_outline_count()):
	# 	debug_draw_polys.append(nav_poly.get_outline(i))
	nav_poly.make_polygons_from_outlines()
	return nav_poly


func get_square_nav_polygon(pos: Vector2) -> PoolVector2Array:
	# var margin_dist := Vector2(NAV_POLY_MARGIN, NAV_POLY_MARGIN).length()
	var poly : PoolVector2Array = [
		Vector2(pos.x - NAV_POLY_MARGIN, pos.y - NAV_POLY_MARGIN),
		Vector2(pos.x + NAV_POLY_MARGIN, pos.y - NAV_POLY_MARGIN),
		Vector2(pos.x + NAV_POLY_MARGIN, pos.y + NAV_POLY_MARGIN),
		Vector2(pos.x - NAV_POLY_MARGIN, pos.y + NAV_POLY_MARGIN),
	]
	return poly
