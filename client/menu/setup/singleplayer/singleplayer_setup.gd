extends MenuControl


func _ready() -> void:
	Network.start_singleplayer()


func _on_BackButton_pressed() -> void:
	change_menu_to_previous()
