tool
extends GridContainer

signal colour_changed(new_value)

export(PackedScene) var swatch_template

# These colours are only used for generating a preview in the editor.
# Actual colours are defined in the Client Player scene.
export(PoolColorArray) var preview_player_colours: PoolColorArray = [
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
] setget set_preview_player_colours


func set_preview_player_colours(value: PoolColorArray) -> void:
	preview_player_colours = value
	generate_swatches(preview_player_colours)


func _ready() -> void:
	if Engine.editor_hint:
		# Generate a preview in the editor when this node is the scene root
		generate_swatches(preview_player_colours)


func generate_swatches(colour_array: PoolColorArray) -> void:
	# Remove old swatches
	for swatch in get_children():
		swatch.queue_free()
	# Create new ones
	for index in colour_array.size():
		var colour = colour_array[index]
		var new_swatch = swatch_template.instance()
		new_swatch.set_colour(colour)
		add_child(new_swatch)
		new_swatch.connect("pressed", self, "select", [index])


func select(choice: int) -> void:
	reset_swatch_selection()
	get_child(choice).set_selected(true)
	emit_signal("colour_changed", choice)


func reset_swatch_selection() -> void:
	for swatch in get_children():
		swatch.set_selected(false)
