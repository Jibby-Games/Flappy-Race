extends Item

export(int) var duration := 10

func _do_use(player) -> void:
	player.start_shrinkage(duration)
