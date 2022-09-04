extends Node2D


func _on_Coin_body_entered(body: Node) -> void:
	if body.has_method("add_coin"):
		body.add_coin()
	# Cannot change this during signal call so defer it
	$Coin.set_deferred("monitoring", false)
	$Coin.hide()
	$RespawnTimer.start()


func _on_RespawnTimer_timeout() -> void:
	$Coin.set_deferred("monitoring", true)
	$Coin.show()
