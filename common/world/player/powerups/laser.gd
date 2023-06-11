extends Powerup

var laser_length := 1000

func _ready() -> void:
	$Area2D/CollisionShape2D.shape.extents.x = laser_length
	$Area2D.position.x = laser_length
	self.hide()
	$Area2D.monitoring = false


func _activate() -> void:
	self.show()
	$Area2D.monitoring = true
	# Add all areas that already overlap
	for body in $Area2D.get_overlapping_bodies():
		kill_player(body)


func _deactivate() -> void:
	self.hide()
	$Area2D.monitoring = false


func _on_Area2D_body_entered(body: Node) -> void:
	kill_player(body)


func kill_player(body) -> void:
	if body == player:
		# Ignore the player with the powerup
		return
	if body is CommonPlayer:
		body.death()
