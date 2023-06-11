extends "res://common/world/player/powerups/invisiberry.gd"

func _activate() -> void:
	._activate()
	player.get_node("Sprites").modulate.a = 0.333
	player.get_node("Trail").modulate.a = 0.333


func _deactivate() -> void:
	._deactivate()
	player.get_node("Sprites").modulate.a = 1.0
	player.get_node("Trail").modulate.a = 1.0
