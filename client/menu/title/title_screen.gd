extends MenuControl


var singleplayer_scene := "res://client/menu/setup/singleplayer/singleplayer_setup.tscn"
var multiplayer_scene := "res://client/menu/lobby/lobby.tscn"
var options_scene := "res://client/menu/options/options.tscn"


func _ready() -> void:
	$Menu/VersionLabel.text = ProjectSettings.get_setting("application/config/version")
	$Menu/Buttons/SingleplayerButton.grab_focus()


func _on_SingleplayerButton_pressed():
	change_menu(singleplayer_scene)
	Network.start_singleplayer()


func _on_MultiplayerButton_pressed():
	change_menu(multiplayer_scene)


func _on_OptionsButton_pressed():
	change_menu(options_scene)


func _on_QuitButton_pressed() -> void:
	get_tree().notification(MainLoop.NOTIFICATION_WM_QUIT_REQUEST)
