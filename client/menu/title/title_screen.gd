extends MenuControl


export(PackedScene) var singleplayer_scene
export(PackedScene) var multiplayer_scene
export(PackedScene) var options_scene


func _ready() -> void:
	$Menu/Buttons/SingleplayerButton.grab_focus()
	# So it doesn't keep restarting
	if MusicPlayer.current_track_name != "drozerix_-_digital_rendezvous.ogg":
		MusicPlayer.play_track_name("drozerix_-_digital_rendezvous.ogg")


func _on_SingleplayerButton_pressed():
	change_menu_to(singleplayer_scene)


func _on_MultiplayerButton_pressed():
	change_menu_to(multiplayer_scene)


func _on_OptionsButton_pressed():
	change_menu_to(options_scene)


func _on_QuitButton_pressed() -> void:
	get_tree().quit()
