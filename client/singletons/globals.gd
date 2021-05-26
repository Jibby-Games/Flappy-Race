extends Node


const HIGH_SCORE_FNAME := "user://highscore.save"


# Public vars
var high_score : int = 0


func _ready():
	high_score = load_high_score()


func load_high_score() -> int:
	var save_file = File.new()
	if not save_file.file_exists(HIGH_SCORE_FNAME):
		return 0

	save_file.open(HIGH_SCORE_FNAME, File.READ)
	var data = parse_json(save_file.get_as_text())
	save_file.close()

	# JSON parsing returns numbers as floats by default
	var score = data['highscore']
	if score and score is float:
		return int(score)
	else:
		reset_high_score()
		return 0


func save_high_score(score: int) -> void:
	high_score = score
	var save_file = File.new()
	save_file.open(HIGH_SCORE_FNAME, File.WRITE)

	# We will store as a JSON object. Overkill for a single integer, but should
	# be easy to scale out.
	var store_dict = {"highscore": score}

	save_file.store_line(to_json(store_dict))
	save_file.close()


func reset_high_score() -> void:
	save_high_score(0)
