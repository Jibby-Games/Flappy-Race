extends Area2D

var is_taken := false


func _on_Pickup_body_entered(body: Node) -> void:
	# Stop one pickup being taken multiple times
	if is_taken:
		return
	is_taken = true
	_on_item_taken(body)


func _on_item_taken(_body: Node) -> void:
	push_error("_on_item_taken must be implemented!")
