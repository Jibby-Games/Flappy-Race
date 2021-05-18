extends CommonWorld


func _ready():
	print(get_path(), ": Server world ready!")


func setup_and_start_game():
	var game_seed = randomize_game_seed()
	Network.Server.send_game_started(game_seed)
	start_game(game_seed)
