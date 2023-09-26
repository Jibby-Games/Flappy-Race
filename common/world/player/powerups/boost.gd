extends Powerup

const WALL_COLLISION_LAYER := 1
const BOOST_AMOUNT := 2000


func _ready() -> void:
	self.hide()


func _activate() -> void:
	self.show()
	player.acceleration.x = BOOST_AMOUNT
	player.set_enable_wall_collisions(false)


func _deactivate() -> void:
	self.hide()
	player.acceleration.x = 0
	player.set_enable_wall_collisions(true)
