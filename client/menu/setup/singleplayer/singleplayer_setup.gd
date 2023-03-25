extends MenuControl

var title_scene := "res://client/menu/title/title_screen.tscn"


func _on_BackButton_pressed() -> void:
	change_menu(title_scene)
