extends Item


func _do_use(player) -> void:
	player.get_node("Magnet").activate_item(duration)
