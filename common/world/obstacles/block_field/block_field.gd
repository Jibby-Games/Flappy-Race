extends Obstacle

tool

const BLOCK_SIZE := 64

export(PackedScene) var Block
export(PackedScene) var CoinSpawner
export(float) var block_density := 0.075 setget set_block_density
export(int) var field_length := 800 setget set_field_length
export(int) var field_height := 1280 setget set_field_height
export(bool) var generate_blocks := false setget _do_generate_blocks
export(int) var checkpoint_distance := 128 setget set_checkpoint_distance
export(int) var max_coins := 3 setget set_max_coins


var blocks := []
var points := []


func _ready() -> void:
	if Engine.is_editor_hint():
		_do_generate_blocks()


func do_generate(game_rng: RandomNumberGenerator) -> void:
	for block in blocks:
		block.queue_free()
	blocks.clear()
	points.clear()
	var blocks_to_spawn: int = int(field_length * field_height * block_density / (BLOCK_SIZE*BLOCK_SIZE))
	var coins_to_spawn: int = game_rng.randi_range(0, max_coins)
	var coins := 0
	for i in blocks_to_spawn:
		var overlap := true
		var iters := 0
		var pos: Vector2
		var failed_blocks := 0
		# Add an iteration limit so we don't get stuck in an infinite loop
		while overlap == true and iters < 100:
			pos = Vector2(game_rng.randf() * field_length, (game_rng.randf()-0.5) * field_height)
			overlap = false
			for point in points:
				if point.distance_to(pos) < 128:
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
		if coins < coins_to_spawn:
			coins += 1
			inst = CoinSpawner.instance()
		else:
			inst = Block.instance()
		inst.position = pos
		blocks.append(inst)
		add_child(inst)
		points.append(pos)
	$"%Checkpoint".position.x = field_length + checkpoint_distance
	$"%PointArea".position.x = $"%Checkpoint".position.x


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
