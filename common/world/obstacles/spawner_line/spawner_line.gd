extends Obstacle

tool

const MAX_LINE_HEIGHT := 1000.0
const MIN_SPACING_PER_ITEM := (1000 / 8)
const MIN_ITEMS := 3
const MAX_ITEMS := int(MAX_LINE_HEIGHT / MIN_SPACING_PER_ITEM)

export(PackedScene) var item_scene: PackedScene
export(float) var line_height := MAX_LINE_HEIGHT setget set_line_height
export(int) var items := 12 setget set_items

var spawned_items := []


func _ready() -> void:
	if Engine.is_editor_hint():
		generate_line(line_height, items)
	for item in spawned_items:
		$SpawnedItems.add_child(item)


func generate_line(new_height: float, num_items: int) -> void:
	for item in spawned_items:
		item.queue_free()
	spawned_items.clear()
	if num_items == 0:
		return
	# -1 from num_items since we need to calculate the number of gaps between
	var increment := new_height / (num_items - 1) if (num_items > 1) else 0.0
	for i in num_items:
		var inst = item_scene.instance()
		# Evenly space items
		inst.position = Vector2(0, (i*increment) - (new_height/2.0))
		spawned_items.append(inst)


func do_generate(_game_rng: RandomNumberGenerator, spawn_items: bool) -> void:
	# Randomise num items and then calculate line height
	assert(MIN_ITEMS <= MAX_ITEMS, "Maximum number of items must be greater than %d! Got: %d" % [MIN_ITEMS, MAX_ITEMS])
	items = _game_rng.randi_range(MIN_ITEMS, MAX_ITEMS) if spawn_items else 0
	line_height = items * MIN_SPACING_PER_ITEM
	generate_line(line_height, items)


func generate_navigation_polygon() -> NavigationPolygon:
	var nav_poly := NavigationPolygon.new()
	nav_poly.add_outline(get_boundary_poly())
	nav_poly.make_polygons_from_outlines()
	return nav_poly


func calculate_length() -> int:
	return $"%Checkpoint".position.x


func set_line_height(value: float) -> void:
	line_height = value
	generate_line(line_height, items)


func set_items(value: int) -> void:
	items = value
	generate_line(line_height, items)
