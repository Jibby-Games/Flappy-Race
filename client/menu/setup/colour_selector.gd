extends GridContainer


signal colour_changed(new_value)


func _ready() -> void:
	for swatch in get_children():
		swatch.connect("pressed", self, "_on_ColourSwatch_pressed", [swatch])


func _on_ColourSwatch_pressed(swatch) -> void:
	reset_swatch_selection()
	swatch.set_selected(true)
	emit_signal("colour_changed", swatch.colour)


func reset_swatch_selection() -> void:
	for swatch in get_children():
		swatch.set_selected(false)
