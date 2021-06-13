extends Control


onready var colour_selector := $Footer/VBoxContainer/ColourSelector
onready var player := $CenterContainer/Control/Player


func _ready() -> void:
	# Disable the player physics so it doesn't fall
	player.set_physics_process(false)
	$Footer/VBoxContainer/StartButton.grab_focus()

	colour_selector.generate_swatches(player.colour_options)
	colour_selector.select(Globals.player_colour)


func _on_StartButton_pressed():
	Network.start_singleplayer()


func _on_ColourSelector_colour_changed(new_value: int) -> void:
	Globals.player_colour = new_value
	player.set_body_colour(new_value)


func _on_BackButton_pressed():
	Network.Client.change_scene("res://client/menu/title/title_screen.tscn")
