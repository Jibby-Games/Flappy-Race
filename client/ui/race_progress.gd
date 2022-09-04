extends Control


var PlayerMarker := preload("res://client/ui/player_marker.tscn")
var players := {}
var active_player_id := 0


export(NodePath) var MarkerAreaPath


onready var MarkerArea := get_node(MarkerAreaPath)


func add_player(player_id: int, player_colour: Color) -> void:
	var marker: TextureRect = PlayerMarker.instance()
	marker.name = str(player_id)
	marker.modulate = player_colour
	# Default markers to below the line
	marker.rect_rotation = 180
	players[player_id] = marker
	MarkerArea.add_child(marker)


func remove_player(player_id: int) -> void:
	if players.has(player_id):
		players[player_id].queue_free()
		var result = players.erase(player_id)
		assert(result)


func set_active_player(new_player_id: int) -> void:
	active_player_id = new_player_id
	for player_id in players:
		if player_id == active_player_id:
			players[player_id].rect_rotation = 0
		else:
			players[player_id].rect_rotation = 180


func set_progress(player_id: int, player_progress: float) -> void:
	if players.has(player_id):
		# Minus the marker size so it doesn't go past the end
		var max_pos = MarkerArea.rect_size.x - players[player_id].rect_size.x
		players[player_id].rect_position.x = min(MarkerArea.rect_size.x * player_progress, max_pos)
