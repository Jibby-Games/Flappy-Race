extends CommonWall


func set_gap(size: float) -> void:
	.set_gap(size)
	$UpperSprite.position.y = $UpperCollider.position.y
	$LowerSprite.position.y = $LowerCollider.position.y


func _on_PointArea_body_entered(body:Node) -> void:
	# Only disable score zone for the local client
	if int(body.name) == multiplayer.get_network_unique_id():
		$PointArea/CollisionShape2D.set_deferred("disabled", true)
