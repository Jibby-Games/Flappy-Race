extends "res://common/world/player/powerups/invisiberry.gd"

func _activate() -> void:
	._activate()
	player.get_node("VisibleBody").modulate.a = 0.333


func _deactivate() -> void:
	._deactivate()
	player.get_node("VisibleBody").modulate.a = 1.0
