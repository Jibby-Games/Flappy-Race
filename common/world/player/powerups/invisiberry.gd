extends Powerup


func _activate() -> void:
	player.set_enable_wall_collisions(false)


func _deactivate() -> void:
	player.set_enable_wall_collisions(true)
