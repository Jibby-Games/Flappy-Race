extends Node

# Public vars
var high_score : int = 0
var game_rng := RandomNumberGenerator.new()


# Randomises the current game RNG seed and returns it
func randomize_game_seed() -> int:
	game_rng.randomize()
	print("[RNG] Generated random seed: ", game_rng.seed)
	return game_rng.seed


# Sets the game RNG seed
func set_game_seed(new_seed) -> void:
	game_rng.seed = new_seed
	print("[RNG] Set game seed to: ", new_seed)
