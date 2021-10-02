extends CanvasLayer


export(NodePath) var HighScorePath
export(NodePath) var ScorePath


onready var HighScore := get_node(HighScorePath)
onready var Score := get_node(ScorePath)


signal request_restart


func _ready() -> void:
	# Setup gubbins
	HighScore.text = str(Globals.high_score)


func update_score(new_score: int) -> void:
	# Actual incrementing is handled on the player object
	Score.text = str(new_score)
	# See if we have a new PB
	if new_score > Globals.high_score:
		Globals.save_high_score(new_score)
		HighScore.text = str(new_score)


func _on_RestartButton_pressed() -> void:
	emit_signal("request_restart")


func show_death() -> void:
	$Death.show()


func show_finished(place: int) -> void:
	$Finished/PlaceLabel.text = int2ordinal(place)
	$Finished/AnimationPlayer.play("Finished")


func show_leaderboard(player_list: Array) -> void:
	$Death.hide()
	$Leaderboard.clear_players()
	for player in player_list:
		var place_text = "DNF" if player.place == null else int2ordinal(player.place)
		$Leaderboard.add_player(player.name, player.colour, place_text, player.score)

	if Network.Client.is_host():
		$Leaderboard/Footer/RestartButton.show()
		$Leaderboard/Footer/RestartButton.grab_focus()
	else:
		$Leaderboard/Footer/RestartButton.hide()
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
