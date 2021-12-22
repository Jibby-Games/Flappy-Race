extends Node


signal flap


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("flap"):
		emit_signal("flap")
