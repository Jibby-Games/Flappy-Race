extends Node2D

func _ready() -> void:
	$AnimationPlayer.play("Explode")
	yield($AnimationPlayer, "animation_finished")
	queue_free()
