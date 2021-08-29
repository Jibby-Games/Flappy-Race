extends VBoxContainer


export(PackedScene) var entry_template


func add_player(player_id: int, player_name: String, colour_choice: int) -> void:
	var player_entry = entry_template.instance()
	player_entry.setup(player_id, player_name, colour_choice)
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
