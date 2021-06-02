extends PopupPanel


func _input(event) -> void:
	if event.is_action_pressed("pause_menu"):
		if visible:
			disable_pause_menu()
		else:
			enable_pause_menu()


func enable_pause_menu() -> void:
	# Only allow the game to be paused in singleplayer
	if Network.Client.is_singleplayer:
		get_tree().paused = true
	self.popup()


func disable_pause_menu() -> void:
	self.hide()
	get_tree().paused = false


func _on_ResumeButton_pressed():
	disable_pause_menu()


func _on_MainMenuButton_pressed():
	Network.stop_networking()
	get_tree().paused = false
	Network.Client.change_scene("res://client/menu/title/title_screen.tscn")


func _on_QuitButton_pressed():
	get_tree().quit()
