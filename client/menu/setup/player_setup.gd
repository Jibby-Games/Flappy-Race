extends Control


var selected_colour : Color = Color.red


func _ready() -> void:
	# Disable the player physics so it doesn't fall
	$CenterContainer/Control/Player.set_physics_process(false)
	$Footer/VBoxContainer/StartButton.grab_focus()


func _on_StartButton_pressed():
	Globals.player_colour = selected_colour
	Network.start_singleplayer()


func _on_ColourSelector_colour_changed(new_value) -> void:
	selected_colour = new_value
	$CenterContainer/Control/Player.set_body_colour(new_value)
