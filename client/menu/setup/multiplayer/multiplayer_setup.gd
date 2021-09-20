extends Control


onready var player_list = $Setup/PlayerList


func populate_players(new_player_list: Dictionary) -> void:
	Logger.print(self, "Got player list: %s" % [new_player_list])
	player_list.clear_players()
	for player_id in new_player_list:
		var colour_choice = new_player_list[player_id]["colour"]
		var player_name = new_player_list[player_id]["name"]
		player_list.add_player(player_id, player_name, colour_choice)


func update_player_colour(player_id: int, colour_choice: int) -> void:
	player_list.update_player_colour(player_id, colour_choice)


func update_player_spectating(player_id: int, is_spectating: bool) -> void:
	player_list.update_player_spectating(player_id, is_spectating)


func _on_BackButton_pressed() -> void:
	Network.Client.change_scene("res://client/menu/lobby/lobby.tscn")


func _on_SpectateButton_toggled(button_pressed: bool) -> void:
	Network.Client.send_player_spectate_change(button_pressed)
	$Setup/SpectatorText.visible = button_pressed
	$Setup/PlayerOptions.visible = not button_pressed
