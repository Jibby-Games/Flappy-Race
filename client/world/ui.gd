extends CanvasLayer


export(NodePath) var HighScorePath
export(NodePath) var ScorePath
export(NodePath) var GameOverPath


onready var HighScore := get_node(HighScorePath)
onready var Score := get_node(ScorePath)
onready var GameOver := get_node(GameOverPath)


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


func show_game_over() -> void:
	GameOver.show()


func _on_RestartButton_pressed() -> void:
	emit_signal("request_restart")
