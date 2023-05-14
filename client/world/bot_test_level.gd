extends Node2D


func _ready() -> void:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	var to_generate := 100
	$Navigation2D/LevelGenerator.generate(rng, to_generate)
	yield($Navigation2D/LevelGenerator, "level_ready")
	for i in to_generate:
		$Navigation2D/LevelGenerator.spawn_obstacle(i)
