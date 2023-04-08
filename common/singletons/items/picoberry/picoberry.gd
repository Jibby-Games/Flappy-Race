extends Item


func _do_use(player) -> void:
	player.start_shrinkage(duration)
