extends Resource

class_name Item

export(String) var name := "Item"
export(Texture) var icon
export(int) var duration := 0


# Public function to use item
func use(player) -> void:
	if duration > 0:
		if not player.has_node(name):
			push_error("You must add a Powerup node to the player scene for item: %s" % name)
			return
		# Items with a duration handle their effects through Powerup nodes
		player.get_node(name).activate_item(duration)
	_do_use(player)


# Internal function to implement the actual item effects
func _do_use(_player) -> void:
	# Do nothing by default
	pass
