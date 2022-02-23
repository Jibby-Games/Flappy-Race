extends Area2D


func _on_Coin_body_entered(body: Node) -> void:
	if body.has_method("add_coin"):
		body.add_coin()
	queue_free()
