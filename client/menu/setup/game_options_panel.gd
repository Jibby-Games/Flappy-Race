extends Control


onready var ScoreInput = $Panel/VBoxContainer/ScoreToWin/ScoreInput
onready var MenuAnimation = $AnimationPlayer
onready var LivesToggle = $Panel/VBoxContainer/PlayerLives/LivesToggle
onready var LivesInput = $Panel/VBoxContainer/PlayerLives/LivesInput


var emit_changes := false


func set_game_options(game_options: Dictionary) -> void:
	set_goal(game_options.goal)
	set_lives(game_options.lives)
	# Don't emit signals the first time the values are set or it can infinitely loop
	emit_changes = true


func set_goal(new_goal: int) -> void:
	ScoreInput.value = new_goal


func set_lives(new_lives: int) -> void:
	if new_lives < 1:
		LivesToggle.pressed = false
		LivesInput.hide()
	else:
		LivesToggle.pressed = true
		LivesInput.value = new_lives
		LivesInput.show()


func _on_GameOptionsToggle_toggled(button_pressed: bool) -> void:
	if button_pressed:
		MenuAnimation.play("OpenPanel")
	else:
		MenuAnimation.play_backwards("OpenPanel")


func _on_ScoreInput_value_changed(new_goal: float) -> void:
	if emit_changes:
		Network.Client.send_goal_change(int(new_goal))


func _on_LivesToggle_toggled(button_pressed: bool) -> void:
		LivesInput.visible = button_pressed
		if emit_changes:
			if button_pressed:
				Network.Client.send_lives_change(int(LivesInput.value))
			else:
				Network.Client.send_lives_change(0)


func _on_LivesInput_value_changed(value: float) -> void:
	if emit_changes:
		Network.Client.send_lives_change(int(value))
