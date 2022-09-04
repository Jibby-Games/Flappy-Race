extends Node


class_name ChunkTracker


signal load_chunk(chunk)
signal unload_chunk(chunk)


var chunk_limit := 0
var chunk_radius := 3
var loaded_chunks := {}
var player_chunks := {}


func add_player(player_id: int, starting_chunk: int = 0) -> void:
	Logger.print(self, "Adding player %s" % player_id)
	assert(not player_chunks.has(player_id))
	player_chunks[player_id] = starting_chunk
	for i in get_chunks_in_radius(starting_chunk):
		load_chunk(i)
	_print_chunks()


func remove_player(player_id: int) -> void:
	Logger.print(self, "Removing player %s" % player_id)
	assert(player_chunks.has(player_id))
	var old_chunk = player_chunks[player_id]
	var result = player_chunks.erase(player_id)
	assert(result)
	# Unload all of the chunks that were around the player
	for i in get_chunks_in_radius(old_chunk):
		unload_chunk(i)


func set_player_chunk(player_id: int, new_chunk: int) -> void:
	var unload_chunks = get_chunks_in_radius(player_chunks[player_id])
	player_chunks[player_id] = new_chunk
	for chunk in unload_chunks:
		unload_chunk(chunk)
	var load_chunks = get_chunks_in_radius(new_chunk)
	for chunk in load_chunks:
		load_chunk(chunk)
	_print_chunks()


func increment_player_chunk(player_id: int) -> void:
	Logger.print(self, "Incrementing player %s" % player_id)
	assert(player_chunks.has(player_id))
	# Must be done first so it's not in range when unloading the chunk
	player_chunks[player_id] += 1
	var load_chunk = player_chunks[player_id] + chunk_radius
	if load_chunk < chunk_limit:
		# Don't load anything past the limit
		load_chunk(load_chunk)
	var unload_chunk = player_chunks[player_id] - chunk_radius - 1
	if unload_chunk >= 0:
		# Players can only go forward so chunk must be positive
		unload_chunk(unload_chunk)
	_print_chunks()


func get_chunks_in_radius(chunk: int) -> Array:
	var min_chunk = max(0, chunk - chunk_radius)
	var max_chunk = min(chunk_limit, chunk + chunk_radius + 1)
	return range(min_chunk, max_chunk)


func load_chunk(chunk: int) -> void:
	if loaded_chunks.has(chunk):
		# Already loaded
		return
	Logger.print(self, "Loaded chunk %s" % chunk)
	loaded_chunks[chunk] = true
	emit_signal("load_chunk", chunk)


func unload_chunk(chunk: int) -> void:
	if is_chunk_in_range_of_any_players(chunk):
		# Another player is still in range of this chunk
		return
	Logger.print(self, "Unloaded chunk %s" % chunk)
	if loaded_chunks.has(chunk):
		var result = loaded_chunks.erase(chunk)
		assert(result)
	emit_signal("unload_chunk", chunk)


func is_chunk_in_range_of_any_players(chunk: int) -> bool:
	for player_chunk in player_chunks.values():
		if (player_chunk - chunk_radius) < chunk and chunk <= (player_chunk + chunk_radius):
			return true
	return false


func _print_chunks():
	Logger.print(self, "Player chunks: %s  Loaded chunks: %s" % [player_chunks, loaded_chunks.keys()])
