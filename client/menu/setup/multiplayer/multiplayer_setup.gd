extends Control


onready var player_list = $PlayerList/List


func _ready() -> void:
	assert(multiplayer.connect("network_peer_disconnected", self, "remove_player") == OK)


func add_player(player_id: int) -> void:
	var player = Label.new()
	player.set_name(str(player_id))
	player.text = str(player_id)
	player_list.add_child(player)


func remove_player(player_id: int) -> void:
	var player = player_list.get_node(str(player_id))
	player.queue_free()


func populate_players(players: PoolIntArray) -> void:
	print("[%s] Got player list: %s" % [get_path().get_name(1), players])
	clear_players()
	for player in players:
		add_player(player)


func clear_players() -> void:
	for child in player_list.get_children():
		child.queue_free()


func _on_BackButton_pressed() -> void:
	Network.stop_networking()
	Network.Client.change_scene("res://client/menu/lobby/lobby.tscn")


func _on_StartButton_pressed() -> void:
	Network.Client.send_start_game_request()


#func _on_ColourSelector_colour_changed(new_value: int):
#	Network.Client.send_player_colour(new_value)
