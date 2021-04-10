extends ColorRect

signal fade_finished

func fade_in():
	$AnimationPlayer.play("fade_in")

func _on_AnimationPlayer_animation_finished(anim_name):
	# only one animation so no need to check animation name
	emit_signal("fade_finished")
