extends Resource

class_name Item

export(String) var name := "Item"
export(Texture) var icon
export(int) var duration := 0


# Public function to use item
func use(player) -> void:
	_do_use(player)


# Internal function to implement the actual item effects
func _do_use(_player) -> void:
	push_error("%s item hasn't implemented the '_do_use' function!" % self.name)
