extends Control

const INITIAL_DELAY_TIME := 1
const PULSE_TIME := 8
const INGAME_DELAY_TIME := 5

export(StreamTexture) var mouse_icon := preload("res://client/ui/controls/Mouse_Left_Key_Light.png")
export(StreamTexture) var keyboard_icon := preload("res://client/ui/controls/Space_Key_Light.png")
export(StreamTexture) var joypad_icon := preload("res://client/ui/controls/XboxSeriesX_A.png")

var checking_for_input := false


func _ready() -> void:
	var result = Input.connect("joy_connection_changed", self, "_on_joy_connection_changed")
	assert(result == OK)
	var devices := Input.get_connected_joypads()
	if devices.empty():
		Logger.print(self, "No joypads detected - using keyboard")
		switch_to_keyboard()
	else:
		for device_id in devices:
			Logger.print(self, "Joypad detected: %s" % Input.get_joy_name(device_id))
		switch_to_joypad()


func _on_joy_connection_changed(device_id: int, connected: bool) -> void:
	if connected:
		Logger.print(self, "Joypad connected: %s" % Input.get_joy_name(device_id))
		switch_to_joypad()
	else:
		var devices := Input.get_connected_joypads()
		if devices.empty():
			Logger.print(self, "All joypads disconnected - using keyboard")
			switch_to_keyboard()


func switch_to_keyboard() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	$CenterContainer/HBoxContainer/LeftIcon.texture = mouse_icon
	$CenterContainer/HBoxContainer/OrLabel.show()
	$CenterContainer/HBoxContainer/RightIcon.texture = keyboard_icon
	$CenterContainer/HBoxContainer/RightIcon.show()


func switch_to_joypad() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	$CenterContainer/HBoxContainer/LeftIcon.texture = joypad_icon
	$CenterContainer/HBoxContainer/OrLabel.hide()
	$CenterContainer/HBoxContainer/RightIcon.hide()


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
	# Change the icons based on inputs
	if event is InputEventJoypadButton or event is InputEventJoypadMotion:
		switch_to_joypad()
	else:
		switch_to_keyboard()
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
