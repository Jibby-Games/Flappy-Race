extends Node

func _ready() -> void:
	var result: int
	result = Network.Server.connect("host_changed", self, "_on_host_changed")
	assert(result == OK)
	result = Network.Server.connect("player_ready_changed", self, "_on_player_ready_changed")
	assert(result == OK)
	reset_players_ready()


func reset_players_ready() -> void:
	for player_id in Network.Server.player_list.keys():
		Network.Server.player_list[player_id].ready = false


func _on_player_ready_changed(player_id: int, is_ready: bool) -> void:
	Network.Server.player_list[player_id].ready = is_ready


func _on_host_changed(old_host_id: int, new_host_id: int) -> void:
	Network.Server.player_list[old_host_id].ready = false
	Network.Server.send_player_ready_update(old_host_id, false)
	Network.Server.player_list[new_host_id].ready = false
	Network.Server.send_player_ready_update(new_host_id, false)
