extends CanvasLayer


export(NodePath) var ScorePath
export(NodePath) var LivesPath
export(NodePath) var CoinsPath
export(NodePath) var SpectateLabelPath
export(NodePath) var RaceProgressPath


onready var Score := get_node(ScorePath)
onready var Lives := get_node(LivesPath)
onready var Coins := get_node(CoinsPath)
onready var SpectateLabel := get_node(SpectateLabelPath)
onready var RaceProgress := get_node(RaceProgressPath)


signal countdown_finished
signal request_restart
signal spectate_change(forward_not_back)


var is_spectating := false


func _ready() -> void:
	# Hide all UI elements by default
	for child in get_children():
		if child is Control:
			child.hide()


func set_player_list(player_list: Dictionary) -> void:
	for player_id in player_list:
		if not player_list[player_id].spectate:
			var colour = Globals.COLOUR_OPTIONS[player_list[player_id].colour]
			RaceProgress.add_player(player_id, colour)


func set_spectating(value: bool) -> void:
	is_spectating = value
	$Ingame/Player.visible = not value
	$Ingame/Spectator.visible = value


func start_countdown() -> void:
	$Countdown.show()
	$Countdown/AnimationPlayer.play("Countdown")


func _countdown_finished() -> void:
	emit_signal("countdown_finished")
	$Ingame/Stopwatch.start()
	$Ingame.show()
	if not is_spectating:
		$Ingame/InputControls.start_checking_for_input()


func update_lives(new_lives: int) -> void:
	Lives.set_lives(new_lives)


func update_score(new_score: int) -> void:
	# Actual incrementing is handled on the player object
	Score.text = str(new_score)


func update_coins(value: int) -> void:
	Coins.text = "%d" % value


func _on_RestartButton_pressed() -> void:
	emit_signal("request_restart")


func show_death() -> void:
	$Ingame/Player.hide()
	$Death.show()
	$Ingame/InputControls.stop_checking_for_input()
	$Death/AnimationPlayer.play("show")


func show_finished(place: int, time: float) -> void:
	$Death.hide()
	$Finished/PlaceLabel.text = int2ordinal(place)
	$Finished/FinishTime.set_time(time)
	$Finished.show()
	$Ingame/InputControls.stop_checking_for_input()
	$Finished/AnimationPlayer.play("Finished")


func show_leaderboard(player_list: Array) -> void:
	$Ingame/Stopwatch.stop()
	$Ingame.hide()
	$Death.hide()
	$Leaderboard.clear_players()
	for player in player_list:
		var place_text := int2ordinal(player.place) if player.has("place") else ""
		var time = player.get("time", 0.0)
		$Leaderboard.add_player(player.name, player.colour, place_text, player.score, time)

	if Network.Client.is_host():
		$Leaderboard/Footer/RestartButton.show()
		$Leaderboard/Footer/RestartButton.grab_focus()
		$Leaderboard/Footer/NewRaceButton.show()
	else:
		$Leaderboard/Footer/RestartButton.hide()
		$Leaderboard/Footer/NewRaceButton.hide()
	$Leaderboard.show()


func int2ordinal(value: int) -> String:
	var digit := value % 10
	var suffix: String

	if digit == 1 and value != 11:
		suffix = "st"
	elif digit == 2 and value != 12:
		suffix = "nd"
	elif digit == 3 and value != 13:
		suffix = "rd"
	else:
		suffix = "th"

	return "%d%s" % [value, suffix]


func set_spectate_player_name(name: String) -> void:
	SpectateLabel.text = "Spectating:\n%s" % name


func _on_NewRaceButton_pressed() -> void:
	Network.Client.send_change_to_setup_request()


func _on_PreviousButton_pressed() -> void:
	emit_signal("spectate_change", false)


func _on_NextButton_pressed() -> void:
	emit_signal("spectate_change", true)
