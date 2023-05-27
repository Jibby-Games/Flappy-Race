extends Node2D

class_name Obstacle

export(bool) var random_height := false

var generated := false
var length: int
var height: int
# The distance from the middle to the boundary at the top and bottom
var boundary_height := 1000
# The distance between this obstacle and the next one
var spacing := 0

onready var Checkpoint: Area2D = $"%Checkpoint"
onready var PointArea: Area2D = $"%PointArea"


func _ready() -> void:
	if generated == false:
		push_error("Obstacle (%s) must be generated before adding it to the scene" % name)
	if length == 0:
		push_error("Obstacle (%s) length must be greater than 0" % name)


func generate(game_rng: RandomNumberGenerator) -> void:
	do_generate(game_rng)
	length = calculate_length()
	# Generate the nav poly for the obstacles
	$"%NavPolygon".position.y = height
	$"%NavPolygon".set_navigation_polygon(generate_navigation_polygon())
	# Generate the nav poly for the spacing after the obstacles
	if spacing > 0:
		$"%SpacingNavPoly".set_navigation_polygon(get_square_navigation_polygon(spacing, boundary_height))
		$"%SpacingNavPoly".position.x = length

	generated = true


func do_generate(_game_rng: RandomNumberGenerator) -> void:
	push_error("Obstacle (%s) must override do_generate when extending the class!" % name)


func calculate_length() -> int:
	push_error("Obstacle (%s) must override calculate_length when extending the class!" % name)
	return 0


func generate_navigation_polygon() -> NavigationPolygon:
	push_error("Obstacle (%s) must override generate_navigation_polygon when extending the class!" % name)
	return null


func get_square_navigation_polygon(nav_length: int, nav_height: int) -> NavigationPolygon:
	var nav_poly := NavigationPolygon.new()
	nav_poly.add_outline([
		Vector2(0, -nav_height),
		Vector2(0, nav_height),
		Vector2(nav_length-200, nav_height),
		Vector2(nav_length-200, -nav_height),
	])
	nav_poly.make_polygons_from_outlines()
	return nav_poly


func get_boundary_poly() -> PoolVector2Array:
	var poly: PoolVector2Array = [
		Vector2(-200, -boundary_height),
		Vector2(-200, boundary_height),
		Vector2(length, boundary_height),
		Vector2(length, -boundary_height),
	]
	return poly


func get_poly(collider: CollisionShape2D) -> PoolVector2Array:
	var poly := PoolVector2Array()
	var extents: Vector2 = collider.shape.extents
	var collider_transform: Transform2D = collider.get_transform()
	poly = [
		# Must use the xform to translate the shape to the correct place, and
		# add an offset so there's a gap between the wall and the nav polygon
		collider_transform.xform(Vector2(-extents.x, -extents.y)) + Vector2(-50, -50),
		collider_transform.xform(Vector2(-extents.x, extents.y)) + Vector2(-50, 50),
		collider_transform.xform(Vector2(extents.x, extents.y)) + Vector2(50, 50),
		collider_transform.xform(Vector2(extents.x, -extents.y)) + Vector2(50, -50),
	]
	# Outlines can't overlap the boundary edges so clamp the y positions of the polygon
	for i in poly.size():
		poly[i].y = clamp(poly[i].y, -boundary_height+1, boundary_height-1)
	return poly
