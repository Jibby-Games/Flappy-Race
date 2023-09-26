extends VBoxContainer

export(PackedScene) var entry_template


func _ready() -> void:
	var result: int
	result = multiplayer.connect("network_peer_disconnected", self, "remove_player")
	assert(result == OK)
	result = Network.Client.connect("host_changed", self, "_on_host_changed")
	assert(result == OK)


func add_player(
		player_id: int,
		player_name: String,
		colour_choice: int,
		spectating: bool,
		is_bot: bool
) -> void:
	var player_entry = entry_template.instance()
	var is_host = Network.Client.is_host_id(player_id)
	player_entry.setup(player_id, player_name, colour_choice, is_bot)
	player_entry.set_host(is_host)
	player_entry.set_spectating(spectating)
	add_child(player_entry)


func remove_player(player_id: int) -> void:
	var player = get_node(str(player_id))
	player.free()


func clear_players() -> void:
	for child in get_children():
		child.free()


func update_player_colour(player_id: int, colour_choice: int) -> void:
	var player = get_node(str(player_id))
	player.set_colour(colour_choice)


func update_player_spectating(player_id: int, is_spectating: bool) -> void:
	var player = get_node(str(player_id))
	player.set_spectating(is_spectating)


func _on_host_changed(new_host_id: int) -> void:
	for player_entry in get_children():
		var entry_is_host: bool = player_entry.player_id == new_host_id
		player_entry.set_host(entry_is_host)
