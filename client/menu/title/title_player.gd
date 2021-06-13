extends Node2D


func _ready():
	randomize()
	reset()


func _physics_process(_delta) -> void:
	# Flap randomly, or when about to go off screen
	var do_flap_roll = rand_range(0, 100)
	if do_flap_roll > 96 or $Player.position.y > get_viewport().size.y:
		$Player.do_flap()


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
