extends "res://common/world/player/powerups/laser.gd"


func _activate() -> void:
	._activate()
	if not $Sound.playing:
		$Sound.play()


func _deactivate() -> void:
	._deactivate()
	$Sound.stop()
