extends "res://common/world/spawners/pickups/pickup.gd"


func _on_item_taken(body: Node) -> void:
	if body.has_method("add_coin"):
		body.add_coin()
