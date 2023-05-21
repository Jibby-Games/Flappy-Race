extends Node2D

var threshold := 100
var remove_when_off_screen := false


func _ready() -> void:
	# Stop death sounds and animations playing on the title screen
	$Player.enable_death = false
	randomize()
	randomise_spawn_position()
	randomise_colour()


func randomise_spawn_position() -> void:
	# Reset position to the left side of the screen somewhere
	var x_pos = rand_range(-threshold, -get_viewport_rect().size.x)
	var y_pos = rand_range(0, get_viewport_rect().size.y)
	$Player.position = Vector2(x_pos, y_pos)


func _physics_process(_delta: float) -> void:
	# Flap randomly, or when about to go below the screen
	var do_flap_roll = rand_range(0, 100)
	if do_flap_roll > 96 or is_below_screen():
		$Player.do_flap()

	if is_right_of_screen():
		if remove_when_off_screen:
			self.queue_free()
		else:
			reset()


func is_below_screen() -> bool:
	return $Player.position.y > get_viewport_rect().size.y


func is_right_of_screen() -> bool:
	return $Player.position.x > get_viewport_rect().size.x + threshold


func reset() -> void:
	# Make player loop back around
	$Player.position.x = -threshold


func randomise_colour() -> void:
	$Player.set_body_colour(Globals.get_random_colour_id())
