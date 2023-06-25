extends Powerup

const WALL_COLLISION_LAYER := 1
const BOOST_AMOUNT := 2000
const ACCELERATION_TIME := 0.5


func _ready() -> void:
	self.hide()


func _activate() -> void:
	self.show()
	# Gradually increase the player's speed
	var tween = create_tween()
	tween.tween_property(player, "acceleration:x", BOOST_AMOUNT, ACCELERATION_TIME)
	player.set_enable_wall_collisions(false)


func _deactivate() -> void:
	self.hide()
	# Gradually slow down the player
	var tween = create_tween()
	tween.tween_property(player, "acceleration:x", 0, ACCELERATION_TIME)
	# Enable collisions again after decelleration
	tween.tween_callback(player, "set_enable_wall_collisions", [true])
