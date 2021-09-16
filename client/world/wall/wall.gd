extends CommonWall


func set_gap(size) -> void:
	var pos = base_wall_height + (size / 2)
	$UpperSprite.position.y = -pos
	$LowerSprite.position.y = pos
	.set_gap(size)
