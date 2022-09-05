extends Control


const INITIAL_DELAY_TIME := 1
const PULSE_TIME := 8
const INGAME_DELAY_TIME := 5


var checking_for_input := false


func start_checking_for_input() -> void:
	checking_for_input = true
	$InputTimer.start(INITIAL_DELAY_TIME)


func stop_checking_for_input() -> void:
	checking_for_input = false
	$DisplayTimer.stop()
	$InputTimer.stop()
	$AnimationPlayer.play("RESET")


func _input(event: InputEvent) -> void:
	if not checking_for_input:
		return
	if event.is_action("flap"):
		if $AnimationPlayer.current_animation == "Icon Pulse":
			# Player knows the controls now, remove the icons
			$DisplayTimer.stop()
			$AnimationPlayer.play_backwards("Fade In")
		# Show the controls again later in case the player forgot
		$InputTimer.start(INGAME_DELAY_TIME)


func _on_InputTimer_timeout() -> void:
	$AnimationPlayer.play("Fade In")
	yield($AnimationPlayer, "animation_finished")
	$AnimationPlayer.play("Icon Pulse")
	$DisplayTimer.start(PULSE_TIME)
	yield($DisplayTimer, "timeout")
	$AnimationPlayer.play_backwards("Fade In")
	$InputTimer.start(INGAME_DELAY_TIME)
