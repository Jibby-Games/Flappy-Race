extends Node


var tracks := []
var current_track_index := 0
var current_track : AudioStreamPlayer
var is_playing := false


func _ready() -> void:
	randomize()
	# Load all music tracks
	for node in get_children():
		if node is AudioStreamPlayer:
			tracks.append(node)
			var result: int
			result = node.connect("finished", self, "_on_track_finished")
			assert(result == OK)


func play_track(track_index: int) -> void:
	if track_index >= tracks.size():
		push_error("Track index %d is out of range. Max is %d" % [track_index, tracks.size()])
		return
	if is_playing:
		current_track.stop()
	else:
		is_playing = true
	current_track = tracks[track_index]
	current_track_index = track_index
	current_track.play()
	Logger.print(self, "Playing track %d: %s " % [current_track_index, current_track.name])


func play_next_track() -> void:
	var next_track = current_track_index + 1
	# Make sure it's a value in the array
	next_track %= tracks.size()
	play_track(next_track)


func play_random_track() -> void:
	var rand_track = randi() % tracks.size()
	# Stop the same song playing again
	if is_playing and rand_track == current_track_index:
		play_next_track()
	else:
		play_track(rand_track)


func play_track_name(track_name: String) -> void:
	for i in tracks.size():
		var track = tracks[i]
		if track.name == track_name:
			play_track(i)
			return
	push_error("Cannot find track named: %s" % [track_name])


func _on_track_finished() -> void:
	if not is_playing:
		# Stops another track playing when stopping
		return
	Logger.print(self, "Finished track %d: %s" % [current_track_index, tracks[current_track_index]])
	play_next_track()


func stop() -> void:
	is_playing = false
	# Should only need to stop the current track
	current_track.stop()
	Logger.print(self, "Stopped playing")
