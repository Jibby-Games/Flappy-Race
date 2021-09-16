extends Control


var goal = 100 setget set_goal


onready var ScoreInput = $Panel/VBoxContainer/ScoreToWin/ScoreInput
onready var MenuAnimation = $AnimationPlayer


func set_goal(new_goal: int) -> void:
	goal = new_goal
	ScoreInput.value = new_goal


func _on_GameOptionsToggle_toggled(button_pressed: bool) -> void:
	if button_pressed:
		MenuAnimation.play("OpenPanel")
	else:
		MenuAnimation.play_backwards("OpenPanel")


func _on_ScoreInput_value_changed(value: float) -> void:
	goal = int(value)
	Network.Client.send_goal_change(goal)
