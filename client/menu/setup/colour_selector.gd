tool
extends GridContainer


signal colour_changed(new_value)

export(PackedScene) var swatch_template
export(PoolColorArray) var player_colours = [
	"#d62411",
	"#7f0622",
	"#ff8426",
	"#ffd100",
	"#ff80a4",
	"#ff2674",
	"#94216a",
	"#430067",
	"#234975",
	"#68aed4",
	"#bfff3c",
	"#10d275",
	"#007899",
	"#002859",
	"#fafdff",
	"#16171a",
] setget set_player_colours


func set_player_colours(value: PoolColorArray) -> void:
	player_colours = value
	generate_swatches(player_colours)


func _ready() -> void:
	if Engine.editor_hint:
		if get_tree().edited_scene_root == self:
			# Only run in the editor when this node is the scene root
			generate_swatches(player_colours)
	else:
		# Only run in game
		for swatch in get_children():
			swatch.connect("pressed", self, "_on_ColourSwatch_pressed", [swatch])
		# Select the first colour by default
		_on_ColourSwatch_pressed(get_child(0))


func generate_swatches(colour_array: PoolColorArray) -> void:
	for swatch in get_children():
		swatch.free()
	for colour in colour_array:
		var new_swatch = swatch_template.instance()
		new_swatch.set_colour(colour)
		add_child(new_swatch)

		new_swatch.set_owner(get_tree().edited_scene_root)


func _on_ColourSwatch_pressed(swatch) -> void:
	reset_swatch_selection()
	swatch.set_selected(true)
	emit_signal("colour_changed", swatch.colour)


func reset_swatch_selection() -> void:
	for swatch in get_children():
		swatch.set_selected(false)
