extends Control


onready var ScoreInput = $Panel/VBoxContainer/ScoreToWin/ScoreInput
onready var MenuAnimation = $AnimationPlayer


func set_goal(new_goal: int) -> void:
	ScoreInput.value = new_goal


func _on_GameOptionsToggle_toggled(button_pressed: bool) -> void:
	if button_pressed:
		MenuAnimation.play("OpenPanel")
	else:
		MenuAnimation.play_backwards("OpenPanel")


func _on_ScoreInput_value_changed(new_goal: float) -> void:
	Network.Client.send_goal_change(int(new_goal))
