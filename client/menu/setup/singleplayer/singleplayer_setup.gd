extends Control


func _ready() -> void:
	Network.start_singleplayer()
	$PlayerCustomiser/StartButton.grab_focus()


func _on_BackButton_pressed():
	Network.Client.change_scene("res://client/menu/title/title_screen.tscn")
