extends Node


const HIGH_SCORE_FNAME := "user://highscore.save"


# Public vars
var high_score : int = 0
var game_rng := RandomNumberGenerator.new()


func _ready():
	high_score = load_high_score()


func load_high_score() -> int:
	var save_file = File.new()
	if not save_file.file_exists(HIGH_SCORE_FNAME):
		return 0

	save_file.open(HIGH_SCORE_FNAME, File.READ)
	var data = parse_json(save_file.get_as_text())
	save_file.close()

	return int(data['highscore'])


func save_high_score(score) -> void:
	var save_file = File.new()
	save_file.open(HIGH_SCORE_FNAME, File.WRITE)

	# We will store as a JSON object. Overkill for a single integer, but should
	# be easy to scale out.
	var store_dict = {"highscore": score}

	save_file.store_line(to_json(store_dict))
	save_file.close()


# Randomises the current game RNG seed and returns it
func randomize_game_seed() -> int:
	game_rng.randomize()
	print("[RNG] Generated random seed: ", game_rng.seed)
	return game_rng.seed


# Sets the game RNG seed
func set_game_seed(new_seed) -> void:
	game_rng.seed = new_seed
	print("[RNG] Set game seed to: ", new_seed)
