extends Control


onready var MenuAnimation = $AnimationPlayer


func _on_GameOptionsToggle_toggled(button_pressed):
	if button_pressed:
		MenuAnimation.play("OpenPanel")
	else:
		MenuAnimation.play_backwards("OpenPanel")
