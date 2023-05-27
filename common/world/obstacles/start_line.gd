extends Node2D

var obstacle_start_pos := 0

func _ready() -> void:
	global_position = Vector2.ZERO
	$NavigationPolygonInstance.set_navigation_polygon(
		get_square_navigation_polygon(obstacle_start_pos, 1000)
	)


func get_square_navigation_polygon(nav_length: int, nav_height: int) -> NavigationPolygon:
	var nav_poly := NavigationPolygon.new()
	nav_poly.add_outline(
		[
			Vector2(0, -nav_height),
			Vector2(0, nav_height),
			Vector2(nav_length - 200, nav_height),
			Vector2(nav_length - 200, -nav_height),
		]
	)
	nav_poly.make_polygons_from_outlines()
	return nav_poly
