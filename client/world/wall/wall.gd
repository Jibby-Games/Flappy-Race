extends CommonWall


func set_gap(size: float) -> void:
	.set_gap(size)
	$UpperSprite.position.y = $UpperCollider.position.y
	$LowerSprite.position.y = $LowerCollider.position.y
