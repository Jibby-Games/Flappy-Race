extends Node2D


func _on_Coin_body_entered(body: Node) -> void:
	if body.has_method("add_coin"):
		body.add_coin()
	$Coin.set_monitoring(false)
	$Coin.hide()
	$RespawnTimer.start()


func _on_RespawnTimer_timeout() -> void:
	$Coin.set_monitoring(true)
	$Coin.show()
