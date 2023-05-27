extends Control

onready var ScoreInput = $Panel/VBoxContainer/ScoreToWin/ScoreInput
onready var LivesToggle = $Panel/VBoxContainer/PlayerLives/LivesToggle
onready var LivesInput = $Panel/VBoxContainer/PlayerLives/LivesInput
onready var BotsToggle = $Panel/VBoxContainer/Bots/BotsToggle
onready var BotsInput = $Panel/VBoxContainer/Bots/BotsInput
onready var BotDifficulty = $Panel/VBoxContainer/BotDifficulty
onready var BotDifficultyInput = $Panel/VBoxContainer/BotDifficulty/Difficulty

var emit_changes := false


func _ready() -> void:
	BotsInput.max_value = Network.MAX_PLAYERS - 1
	for diff in CommonWorld.Difficulty.keys():
		var text: String = diff.replace("_", " ")
		BotDifficultyInput.add_item(text, CommonWorld.Difficulty[diff])
	BotDifficultyInput.select(CommonWorld.Difficulty.MEDIUM)


func set_enable_host_options(is_host: bool) -> void:
	$Panel/DisableGameOptions.visible = not is_host
	ScoreInput.editable = is_host
	LivesToggle.disabled = not is_host
	LivesInput.editable = is_host
	BotsToggle.disabled = not is_host
	BotsInput.editable = is_host
	BotDifficultyInput.disabled = not is_host


func set_game_options(game_options: Dictionary) -> void:
	set_goal(game_options.goal)
	set_lives(game_options.lives)
	set_bots(game_options.bots)
	set_difficulty(game_options.difficulty)
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


func set_bots(new_bots: int) -> void:
	if new_bots < 1:
		BotsToggle.pressed = false
		BotsInput.hide()
		BotDifficulty.hide()
	else:
		BotsToggle.pressed = true
		BotsInput.value = new_bots
		BotsInput.show()
		BotDifficulty.show()


func set_max_bots(new_max: int) -> void:
	BotsInput.max_value = new_max


func set_difficulty(value: int) -> void:
	BotDifficultyInput.select(value)


func _on_ScoreInput_value_changed(new_goal: float) -> void:
	if emit_changes:
		Network.Client.send_game_option_change("goal", int(new_goal))


func _on_LivesToggle_toggled(button_pressed: bool) -> void:
	LivesInput.visible = button_pressed
	if emit_changes:
		if button_pressed:
			Network.Client.send_game_option_change("lives", int(LivesInput.value))
		else:
			Network.Client.send_game_option_change("lives", 0)


func _on_LivesInput_value_changed(value: float) -> void:
	if emit_changes:
		Network.Client.send_game_option_change("lives", int(value))


func _on_BotsToggle_toggled(button_pressed: bool) -> void:
	BotsInput.visible = button_pressed
	if emit_changes:
		if button_pressed:
			Network.Client.send_game_option_change("bots", int(BotsInput.value))
		else:
			Network.Client.send_game_option_change("bots", 0)


func _on_BotsInput_value_changed(value: float) -> void:
	if emit_changes:
		Network.Client.send_game_option_change("bots", int(value))


func _on_Difficulty_item_selected(index: int) -> void:
	if emit_changes:
		Network.Client.game_options.difficulty = index
		Network.Client.send_game_option_change("difficulty", index)
