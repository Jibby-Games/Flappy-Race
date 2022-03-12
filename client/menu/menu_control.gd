extends Control


class_name MenuControl


signal change_menu(next_scene)


func change_menu(next_menu_path: String):
	emit_signal("change_menu", next_menu_path)
