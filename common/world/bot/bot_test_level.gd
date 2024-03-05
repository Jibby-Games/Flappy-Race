extends Node2D

var player := preload("res://client/world/player/player.tscn")
var bot_controller := preload("res://common/world/bot/bot_controller.tscn")

var bots := 10

func _ready() -> void:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	var to_generate := 100
	$Navigation2D/LevelGenerator.generate(rng, to_generate)
	yield($Navigation2D/LevelGenerator, "level_ready")
	for i in to_generate:
		$Navigation2D/LevelGenerator.spawn_obstacle(i)
	for i in bots:
		var bot := player.instance()
		bot.add_child(bot_controller.instance())
		$Navigation2D.add_child(bot)
		if i == 0:
			var camera := Camera2D.new()
			camera.current = true
			camera.zoom = Vector2(4, 4)
			bot.add_child(camera)
