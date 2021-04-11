extends Control

var scene_path_to_load

func _ready():
	$MarginContainer/Menu/CenterRow/Buttons/NewGameButton.grab_focus()
	for button in $MarginContainer/Menu/CenterRow/Buttons.get_children():
		button.connect("pressed", self, "on_Button_pressed", [button.scene_to_load])

func on_Button_pressed(scene_to_load):
	scene_path_to_load = scene_to_load
	$FadeIn.show()
	$FadeIn.fade_in()

func _on_FadeIn_fade_finished():
	get_tree().change_scene(scene_path_to_load)


func _on_BGMusic_finished():
	$BGMusic.play()
