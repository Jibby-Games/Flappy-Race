extends Button


func _on_Solo_pressed():
	print("Solo pressed!")
	get_tree().change_scene("res://scenes/World.tscn")
