extends Node2D


func _on_Item_body_entered(_body: Node) -> void:
	# Cannot change this during signal call so defer it
	$Item.set_deferred("monitoring", false)
	$Item.hide()
	$RespawnTimer.start()


func _on_RespawnTimer_timeout() -> void:
	# Reset position in case it's been moved by a magnet
	$Item.position = Vector2.ZERO
	$Item.set_deferred("monitoring", true)
	$Item.show()
