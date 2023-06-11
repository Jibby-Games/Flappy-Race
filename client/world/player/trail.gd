extends Line2D

var max_points := 6
var clear_distance := 10000
var last_position := Vector2.ZERO


func _ready() -> void:
	set_as_toplevel(true)


func _physics_process(_delta: float) -> void:
	var current_position: Vector2 = get_parent().global_position
	# Stops the trail streaking across the screen if it teleports
	if last_position.distance_squared_to(current_position) > clear_distance:
		clear_points()
	add_point(current_position)
	if get_point_count() > max_points:
		remove_point(0)
	last_position = current_position
