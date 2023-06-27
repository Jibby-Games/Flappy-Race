extends "res://common/world/player/powerups/magnet.gd"


func _activate() -> void:
	._activate()
	if not $MagnetSound.playing:
		$MagnetSound.play()


func _deactivate() -> void:
	._deactivate()
	$MagnetSound.stop()
