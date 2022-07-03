extends Control


export var LeaderboardEntry: PackedScene


func add_player(player_name: String, colour: int, place_text: String, score: int, time: float) -> void:
	var entry = LeaderboardEntry.instance()
	var player_body = entry.get_node("PlayerHolder/Player")
	# Stop player from falling
	player_body.set_enable_movement(false)
	player_body.set_body_colour(colour)
	var label = entry.get_node("Name")
	label.text = player_name
	var place = entry.get_node("Place")
	if place_text.empty():
		place.hide()
		entry.get_node("Skull").show()
	else:
		place.text = place_text
	var score_label = entry.get_node("Score")
	score_label.text = str(score)
	var time_label = entry.get_node("Time")
	if place_text.empty():
		time_label.hide()
	else:
		time_label.set_time(time)
	$VBoxContainer/ScrollContainer/EntryList.add_child(entry)


func clear_players() -> void:
	for entry in $VBoxContainer/ScrollContainer/EntryList.get_children():
		entry.queue_free()
