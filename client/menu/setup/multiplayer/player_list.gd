extends VBoxContainer


export(PackedScene) var entry_template


func add_player(player_id: int) -> void:
	var player_entry = entry_template.instance()
	player_entry.setup(player_id)
	add_child(player_entry)


func remove_player(player_id: int) -> void:
	var player = get_node(str(player_id))
	player.queue_free()


func clear_players() -> void:
	for child in get_children():
		child.queue_free()
