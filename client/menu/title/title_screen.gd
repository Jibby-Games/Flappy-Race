extends Control


func _ready():
	$MarginContainer/Menu/CenterRow/Buttons/SingleplayerButton.grab_focus()
	for button in $MarginContainer/Menu/CenterRow/Buttons.get_children():
		button.connect("pressed", self, "_on_MenuButton_pressed", [button.scene_to_load])


func _on_MenuButton_pressed(scene_to_load):
	$FadeIn.show()
	$FadeIn.fade_in()
	yield($FadeIn, "fade_finished")
	if scene_to_load != null:
		Network.Client.change_scene_to(scene_to_load)


func _on_BGMusic_finished():
	$BGMusic.play()


func _on_SingleplayerButton_pressed():
	Network.Server.singleplayer = true
	Network.Server.start_server(Network.RPC_PORT, Network.MAX_PLAYERS)
	Network.Client.start_client("127.0.0.1", Network.RPC_PORT)
