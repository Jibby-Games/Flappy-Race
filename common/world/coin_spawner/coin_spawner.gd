extends Node2D


func _on_Coin_body_entered(body: Node) -> void:
	if body.has_method("add_coin"):
		body.add_coin()
	# Cannot change this during signal call so defer it
	$Coin.set_deferred("monitoring", false)
	$Coin.hide()
	$RespawnTimer.start()


func _on_RespawnTimer_timeout() -> void:
	# Reset position in case it's been moved by a magnet
	$Coin.position = Vector2.ZERO
	$Coin.set_deferred("monitoring", true)
	$Coin.show()
