tool
extends Button


export(bool) var selected = false setget set_selected
export(Color) var colour = Color.white setget set_colour


func set_colour(new_value: Color) -> void:
	if colour != new_value:
		colour = new_value
		self_modulate = new_value
		update()


func set_selected(new_value: bool) -> void:
	if selected != new_value:
		selected = new_value
		$Selected.visible = new_value
		update()
