extends Control


export(PackedScene) var singleplayer_scene
export(PackedScene) var multiplayer_scene
export(PackedScene) var options_scene


func _ready() -> void:
	$Menu/Buttons/SingleplayerButton.grab_focus()


func start_fade() -> void:
	$FadeIn.show()
	$FadeIn.fade_in()


func _on_BGMusic_finished() -> void:
	$BGMusic.play()


func _on_SingleplayerButton_pressed() -> void:
	start_fade()
	yield($FadeIn, "fade_finished")
	Network.Client.change_scene_to(singleplayer_scene)


func _on_MultiplayerButton_pressed() -> void:
	start_fade()
	yield($FadeIn, "fade_finished")
	Network.Client.change_scene_to(multiplayer_scene)


func _on_OptionsButton_pressed() -> void:
	start_fade()
	yield($FadeIn, "fade_finished")
	Network.Client.change_scene_to(options_scene)


func _on_QuitButton_pressed() -> void:
	get_tree().quit()
