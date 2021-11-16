extends Control


class_name MenuControl


signal change_menu_to(next_scene)
signal change_menu_to_previous


func change_menu_to(next_menu: PackedScene):
	emit_signal("change_menu_to", next_menu)


func change_menu_to_previous() -> void:
	emit_signal("change_menu_to_previous")

