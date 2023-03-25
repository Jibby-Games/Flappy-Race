extends Obstacle

tool

export(PackedScene) var CoinSpawner := preload("res://client/world/coin_spawner/coin_spawner.tscn")
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
		var inst = CoinSpawner.instance()
		# Offset by radius so length calculations are correct
		inst.position = Vector2(new_radius, 0) + pos
		add_child(inst)
		spawned_coins.append(inst)


func do_generate(_game_rng: RandomNumberGenerator) -> void:
	# Nothing to generate
	pass


func calculate_length() -> int:
	return $"%Checkpoint".position.x


func set_radius(value: float) -> void:
	radius = value
	generate_circle(radius, coins)


func set_coins(value: int) -> void:
	coins = value
	generate_circle(radius, coins)
