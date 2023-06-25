extends "res://common/world/player/powerups/boost.gd"


func _ready() -> void:
	$Particles2D.set_emitting(false)


func _activate() -> void:
	._activate()
	$Particles2D.set_emitting(true)
	$InitialSound.play()
	if not $LoopingSound.playing:
		$LoopingSound.play()


func _deactivate() -> void:
	._deactivate()
	$LoopingSound.stop()
	$Particles2D.set_emitting(false)
