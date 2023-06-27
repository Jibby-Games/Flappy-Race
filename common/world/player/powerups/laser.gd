extends Powerup

var laser_length := 2000


func _ready() -> void:
	self.hide()
	self.set_physics_process(false)
	$LaserRaycast.cast_to = Vector2(laser_length, 0)
	$LaserRaycast.add_exception(player)


func _activate() -> void:
	self.show()
	self.set_physics_process(true)


func _deactivate() -> void:
	self.hide()
	self.set_physics_process(false)


func _physics_process(_delta: float) -> void:
	if $LaserRaycast.is_colliding():
		var player_body = $LaserRaycast.get_collider()
		kill_player(player_body)


func kill_player(body) -> void:
	if body == player:
		# Ignore the player with the powerup
		return
	if body is CommonPlayer:
		body.death()
