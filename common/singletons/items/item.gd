class_name Item extends Resource

export(String) var name := "Item"
export(Texture) var icon
export(int) var duration := 0
export(Dictionary) var distance_weights = {
	0: 10,
	400: 10,
	1000: 10,
	5000: 10,
	10000: 10,
	20000: 10,
	50000: 10,
}


# Public function to use item
func use(player) -> void:
	_do_use(player)


# Internal function to implement the actual item effects
func _do_use(player) -> void:
	# By default activate the powerup node on the player
	# Override this for different effects
	if not player.has_node(name):
		push_error("You must add a Powerup node to the player scene for item: %s" % name)
		return
	player.get_node(name).activate_item(duration)
