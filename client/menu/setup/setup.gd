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

	# Update for any host changes
	var result: int
	result = Network.Client.connect("host_changed", self, "_on_host_changed")
	assert(result == OK)

	# Need to defer this or the menu animation hides it
	$StartButton.call_deferred("grab_focus")


func _on_host_changed(_new_host: int) -> void:
	set_enable_host_options(Network.Client.is_host())


func set_enable_host_options(is_host: bool) -> void:
	$StartButton.visible = is_host
	$GameOptions/Panel/DisableGameOptions.visible = not is_host
	$GameOptions/Panel/VBoxContainer/ScoreToWin/ScoreInput.editable = is_host
	$GameOptions/Panel/VBoxContainer/PlayerLives/LivesToggle.disabled = not is_host
	$GameOptions/Panel/VBoxContainer/PlayerLives/LivesInput.editable = is_host


func _on_BackButton_pressed() -> void:
	Network.stop_networking()


func _on_StartButton_pressed() -> void:
	Network.Client.send_start_game_request()


func _on_ColourSelector_colour_changed(new_value: int) -> void:
	if new_value != Globals.player_colour:
		Globals.player_colour = new_value
		player.set_body_colour(new_value)
		Network.Client.send_player_colour_change(new_value)
