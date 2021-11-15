extends MenuControl


func _ready() -> void:
	Network.start_singleplayer()
	$Setup/StartButton.grab_focus()


func _on_BackButton_pressed() -> void:
	change_menu_to_previous()
