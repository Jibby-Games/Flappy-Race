extends Control


onready var player_list = $PlayerList


func _ready() -> void:
	assert(multiplayer.connect("network_peer_disconnected", self, "remove_player") == OK)


func populate_players(players: PoolIntArray) -> void:
	print("[%s] Got player list: %s" % [get_path().get_name(1), players])
	player_list.clear_players()
	for player in players:
		player_list.add_player(player)


func _on_BackButton_pressed() -> void:
	Network.stop_networking()
	Network.Client.change_scene("res://client/menu/lobby/lobby.tscn")


func _on_StartButton_pressed() -> void:
	Network.Client.send_start_game_request()


func _on_ColourSelector_colour_changed(new_value: int) -> void:
	Network.Client.send_player_colour_change(new_value)
