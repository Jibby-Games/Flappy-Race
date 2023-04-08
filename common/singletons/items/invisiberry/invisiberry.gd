extends Item


func _do_use(player) -> void:
	player.start_invisibility(duration)
