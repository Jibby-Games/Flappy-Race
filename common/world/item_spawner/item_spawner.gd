extends Node2D


func _on_Item_body_entered(body: Node) -> void:
	if body.has_method("add_item"):
		var item := Items.pick_item()
		body.add_item(item)
	# Cannot change this during signal call so defer it
	$Item.set_deferred("monitoring", false)
	$Item.hide()
	$RespawnTimer.start()


func _on_RespawnTimer_timeout() -> void:
	$Item.set_deferred("monitoring", true)
	$Item.show()
