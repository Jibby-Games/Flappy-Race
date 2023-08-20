extends Area2D


func _on_Pickup_body_entered(body: Node) -> void:
	_on_item_taken(body)


func _on_item_taken(_body: Node) -> void:
	push_error("_on_item_taken must be implemented!")
