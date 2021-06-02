extends PopupPanel


func _input(event) -> void:
	if event.is_action_pressed("pause_menu"):
		if visible:
			disable_pause_menu()
		else:
			enable_pause_menu()


func enable_pause_menu() -> void:
	get_tree().paused = true
	self.popup()


func disable_pause_menu() -> void:
	self.hide()
	get_tree().paused = false


func _on_ResumeButton_pressed():
	disable_pause_menu()


func _on_MainMenuButton_pressed():
	Network.Client.stop_client()
	Network.Server.stop_server()
	get_tree().paused = false
	Network.Client.change_scene("res://client/menu/title/title_screen.tscn")


func _on_QuitButton_pressed():
	get_tree().quit()
