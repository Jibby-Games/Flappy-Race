extends StaticBody2D


class_name CommonWall


var base_wall_height = 640
var gap = 200


func _ready():
	set_gap(gap)


func set_gap(size):
	var pos = base_wall_height + (size / 2)
	$UpperCollider.position.y = -pos
	$LowerCollider.position.y = pos
