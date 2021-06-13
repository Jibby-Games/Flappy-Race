extends Control


func _ready() -> void:
	$PlayerCustomiser/Footer/VBoxContainer/StartButton.grab_focus()


func _on_StartButton_pressed():
	Network.start_singleplayer()


func _on_BackButton_pressed():
	Network.Client.change_scene("res://client/menu/title/title_screen.tscn")
