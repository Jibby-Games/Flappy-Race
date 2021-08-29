extends Control


onready var colour_selector := $PlayerOptions/Control/ColourSelector
onready var player := $PlayerOptions/Control/Player


func _ready() -> void:
	# Disable the player physics so it doesn't fall
	player.set_physics_process(false)

	# Create the colour selector
	colour_selector.generate_swatches(player.colour_options)

	# Set the saved player colour
	player.set_body_colour(Globals.player_colour)
	colour_selector.select(Globals.player_colour)


func _on_BackButton_pressed() -> void:
	Network.stop_networking()


func _on_StartButton_pressed() -> void:
	Network.Client.send_start_game_request()


func _on_ColourSelector_colour_changed(new_value: int) -> void:
	if new_value != Globals.player_colour:
		Globals.player_colour = new_value
		player.set_body_colour(new_value)
		Network.Client.send_player_colour_change(new_value)
