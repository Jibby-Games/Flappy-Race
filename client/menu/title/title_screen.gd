extends MenuControl


export(PackedScene) var singleplayer_scene
export(PackedScene) var multiplayer_scene
export(PackedScene) var options_scene


func _ready() -> void:
	$Menu/VersionLabel.text = ProjectSettings.get_setting("application/config/version")
	$Menu/Buttons/SingleplayerButton.grab_focus()


func _on_SingleplayerButton_pressed():
	change_menu_to(singleplayer_scene)
	Network.start_singleplayer()


func _on_MultiplayerButton_pressed():
	change_menu_to(multiplayer_scene)


func _on_OptionsButton_pressed():
	change_menu_to(options_scene)


func _on_QuitButton_pressed() -> void:
	get_tree().notification(MainLoop.NOTIFICATION_WM_QUIT_REQUEST)
