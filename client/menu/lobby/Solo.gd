extends Button


func _on_Solo_pressed():
	# Tell the game to start in offline mode
	Net.is_online = false
	assert(Globals.randomize_game_seed())
	# And start the actual game
	SceneManager.change_to(Enums.Scene.WORLD)
