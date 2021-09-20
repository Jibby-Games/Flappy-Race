extends Control


export var LeaderboardEntry: PackedScene


func add_player(player_name: String, colour: int, place_text: String) -> void:
	var entry = LeaderboardEntry.instance()
	var player_body = entry.get_node("PlayerHolder/Player")
	# Stop player from falling
	player_body.set_enable_movement(false)
	player_body.set_body_colour(colour)
	var label = entry.get_node("Name")
	label.text = player_name
	var place = entry.get_node("Place")
	place.text = place_text
	$VBoxContainer/ScrollContainer/EntryList.add_child(entry)


func clear_players() -> void:
	for entry in $VBoxContainer/ScrollContainer/EntryList.get_children():
		entry.queue_free()
