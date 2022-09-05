extends Obstacle


const BLOCK_SIZE := 64



export(PackedScene) var CoinSpawner


var height_range := 100
var gap_range_min := 135
var gap_range_max := 150
var length_min = 4
var length_max = 12
var spawn_coin_chance := 0.5
var max_coins := 3


func do_generate(game_rng: RandomNumberGenerator) -> void:
	var length: int = game_rng.randi_range(length_min, length_max)
	set_length(length)
	var height: float = game_rng.randf_range(-height_range, height_range)
	$Tunnel.position.y = height
	$"%Checkpoint".position.y = height
	$PointArea.position.y = height
	var gap: float = game_rng.randf_range(gap_range_min, gap_range_max)
	set_gap(gap)
	var should_spawn_coin: bool = game_rng.randf() < spawn_coin_chance
	if should_spawn_coin:
		var increment = $Tunnel/Top.shape.extents.x / (max_coins - 1)
		for i in max_coins:
			var spawner = CoinSpawner.instance()
			spawner.position.x = increment * (i + 1)
			$Tunnel.add_child(spawner)


func calculate_length() -> int:
	return $"%Checkpoint".position.x


func set_length(blocks: int) -> void:
	var length = blocks * BLOCK_SIZE
	# Can't change existing collider shapes so create a new one
	var collider = RectangleShape2D.new()
	collider.extents = Vector2(length, 800)
	$Tunnel/Top.shape = collider
	$Tunnel/Top.position.x = length
	$Tunnel/Bottom.position.x = length
	$Tunnel/Bottom.shape = collider
	$"%Checkpoint".position.x = length * 2 + 100
	$PointArea.position.x = $"%Checkpoint".position.x


func set_gap(size: float) -> void:
	var rect_collider_pos = $Tunnel/Top.shape.extents.y + (size / 2)
	$Tunnel/Bottom.position.y = rect_collider_pos
	$Tunnel/Top.position.y = -rect_collider_pos