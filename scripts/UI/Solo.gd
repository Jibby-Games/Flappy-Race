extends Button


func _on_Solo_pressed():
	# Tell the game to start in offline mode
	Net.is_online = false
	var _junk
	_junk = Globals.randomize_game_seed()
	# And start the actual game
	_junk = get_tree().change_scene("res://scenes/World.tscn")
