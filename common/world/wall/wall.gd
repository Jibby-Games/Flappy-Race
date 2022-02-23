extends StaticBody2D


class_name CommonWall


export(PackedScene) var Coin


# Half the height of one of the walls
var half_wall_height = 640
# The gap between the upper and lower walls
var gap = 320 setget set_gap


func set_gap(size: float) -> void:
	gap = size
	var rect_collider_pos = half_wall_height + (gap / 2)
	$LowerCollider.position.y = rect_collider_pos
	$UpperCollider.position.y = -rect_collider_pos


func _on_PointArea_body_entered(body: Node) -> void:
	if body.has_method("add_score"):
		body.add_score()


func spawn_coin() -> void:
	var coin = Coin.instance()
	add_child(coin)
