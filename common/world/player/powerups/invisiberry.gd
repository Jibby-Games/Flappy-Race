extends Powerup

const WALL_COLLISION_LAYER := 1

func _activate() -> void:
	player.set_collision_mask_bit(WALL_COLLISION_LAYER, false)
	player.get_node("Detect").set_collision_mask_bit(WALL_COLLISION_LAYER, false)


func _deactivate() -> void:
	player.set_collision_mask_bit(WALL_COLLISION_LAYER, true)
	player.get_node("Detect").set_collision_mask_bit(WALL_COLLISION_LAYER, true)
