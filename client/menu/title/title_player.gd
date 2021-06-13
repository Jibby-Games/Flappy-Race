extends Node2D


func _ready():
	randomise_start_position()


func _physics_process(_delta) -> void:
	# Randomly flap, or when about to go off screen
	var do_flap_roll = rand_range(0, 100)
	if do_flap_roll > 96 or $Player.position.y > get_viewport().size.y:
		$Player.do_flap()


func randomise_start_position():
	# Reset position to the left side of the screen somewhere
	var x_pos = rand_range(0, -2000)
	var y_pos = rand_range(0, get_viewport().size.y)
	$Player.position = Vector2(x_pos, y_pos)
