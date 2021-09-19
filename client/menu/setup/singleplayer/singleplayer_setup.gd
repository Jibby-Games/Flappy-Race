extends Control


func _ready() -> void:
	Network.start_singleplayer()
	$Setup/StartButton.grab_focus()


func _on_BackButton_pressed() -> void:
	Network.Client.change_scene("res://client/menu/title/title_screen.tscn")
