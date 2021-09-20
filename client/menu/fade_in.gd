extends ColorRect

signal fade_finished

func fade_in() -> void:
	$AnimationPlayer.play("fade_in")

func _on_AnimationPlayer_animation_finished(_anim_name: String) -> void:
	# only one animation so no need to check animation name
	emit_signal("fade_finished")
