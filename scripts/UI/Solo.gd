extends Button


func _on_Solo_pressed():
	# Tell the game to start in offline mode
	Net.is_online = false
	# And start the actual game
	var _junk = get_tree().change_scene("res://scenes/World.tscn")
