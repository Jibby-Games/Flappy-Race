extends Powerup

export(PackedScene) var flomb_projectile = preload("res://common/world/items/flomb_projectile.tscn")

func _activate() -> void:
	# Deliberately empty - logic on server side
	pass
