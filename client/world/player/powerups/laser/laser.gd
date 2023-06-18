extends "res://common/world/player/powerups/laser.gd"


func _activate() -> void:
	._activate()
	$LaserBeam2D.max_length = laser_length
	$LaserBeam2D.set_is_casting(true)
	if not $Sound.playing:
		$Sound.play()


func _deactivate() -> void:
	._deactivate()
	$Sound.stop()
	$LaserBeam2D.set_is_casting(false)
