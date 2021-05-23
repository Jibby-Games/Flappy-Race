extends CommonWorld


func _ready():
	print(get_path(), ": Server world ready!")


func setup_and_start_game():
	var game_seed = randomize_game_seed()
	Network.Server.send_game_started(game_seed)
	start_game(game_seed)


func _on_Player_death(player) -> void:
	Network.Server.send_despawn_player(int(player.name))
	._on_Player_death(player)
