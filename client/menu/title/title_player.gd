extends Node2D


func _ready() -> void:
	# Stop death sounds playing on the title screen
	$Player/DeathSound.stream_paused = true
	randomize()
	reset()


func _physics_process(_delta: float) -> void:
	# Flap randomly, or when about to go below the screen
	var do_flap_roll = rand_range(0, 100)
	if do_flap_roll > 96 or is_below_screen():
		$Player.do_flap()

	if is_right_of_screen():
		reset()


func is_below_screen() -> bool:
	return $Player.position.y > get_viewport().size.y


func is_right_of_screen() -> bool:
	return $Player.position.x > get_viewport().size.x


func reset() -> void:
	randomise_start_position()
	randomise_colour()


func randomise_start_position() -> void:
	# Reset position to the left side of the screen somewhere
	var x_pos = rand_range(-100, -2000)
	var y_pos = rand_range(0, get_viewport().size.y)
	$Player.position = Vector2(x_pos, y_pos)


func randomise_colour() -> void:
	var colour_choice = randi() % $Player.colour_options.size()
	$Player.set_body_colour(colour_choice)
