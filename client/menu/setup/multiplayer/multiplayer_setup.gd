extends Control


onready var player_list = $PlayerCustomiser/PlayerList


func _ready() -> void:
	assert(multiplayer.connect("network_peer_disconnected", self, "remove_player") == OK)


func populate_players(new_player_list: Dictionary) -> void:
	print("[%s] Got player list: %s" % [get_path().get_name(1), new_player_list])
	player_list.clear_players()
	for player_id in new_player_list:
		var colour_choice = new_player_list[player_id]["colour"]
		var player_name = new_player_list[player_id]["name"]
		player_list.add_player(player_id, player_name, colour_choice)


func update_player(player_id: int, colour_choice: int) -> void:
	player_list.update_player(player_id, colour_choice)


func _on_BackButton_pressed() -> void:
	Network.stop_networking()
	Network.Client.change_scene("res://client/menu/lobby/lobby.tscn")


func _on_StartButton_pressed() -> void:
	Network.Client.send_start_game_request()


func _on_ColourSelector_colour_changed(new_value: int) -> void:
	Network.Client.send_player_colour_change(new_value)
