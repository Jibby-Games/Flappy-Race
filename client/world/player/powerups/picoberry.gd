extends "res://common/world/player/powerups/picoberry.gd"


func _activate() -> void:
	._activate()
	player.get_node("VisibleBody/Trail").width = 28


func _deactivate() -> void:
	._deactivate()
	player.get_node("VisibleBody/Trail").width = 56
