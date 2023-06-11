extends Powerup


func _activate() -> void:
	player.scale = Vector2(0.5, 0.5)


func _deactivate() -> void:
	player.scale = Vector2.ONE
