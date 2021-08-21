extends Control


onready var colour_selector := $PlayerOptions/Control/ColourSelector
onready var player := $PlayerOptions/Control/Player


func _ready() -> void:
	# Disable the player physics so it doesn't fall
	player.set_physics_process(false)

	# Create the colour selector
	colour_selector.generate_swatches(player.colour_options)
	colour_selector.select(Globals.player_colour)


func _on_ColourSelector_colour_changed(new_value: int) -> void:
	Globals.player_colour = new_value
	player.set_body_colour(new_value)
