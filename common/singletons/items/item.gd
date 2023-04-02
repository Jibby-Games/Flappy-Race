extends Resource

class_name Item

export(String) var name
export(Texture) var icon


# Public function to use item
func use(player) -> void:
	Logger.print(player, "Player %s used item: %s!", [player.name, self.name])
	_do_use(player)


# Internal function to implement the actual item effects
func _do_use(_player) -> void:
	push_error("%s item hasn't implemented the '_do_use' function!" % self.name)
