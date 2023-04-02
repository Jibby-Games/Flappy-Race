extends Resource

class_name Item

export(String) var name
export(Texture) var icon


func use(_player) -> void:
	push_error("%s item hasn't implemented the 'use' function!" % self.name)
