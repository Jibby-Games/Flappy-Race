extends AudioStreamPlayer

var music_file_path := "res://client/music/"
var supported_filetypes := ["ogg"]
var tracks := []
var current_track := 0


func _ready():
	tracks = load_music(music_file_path)


func load_music(path: String) -> Array:
	print("[%s] Loading music files" % [get_path().get_name(1)])
	var files := []
	var dir = Directory.new()
	if dir.open(path) != OK:
		push_error("[%s] An error occurred when trying to access the path: %s" % [get_path().get_name(1), path])
		return []

	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if supported_filetypes.has(file_name.get_extension()):
			files.append(file_name)
		file_name = dir.get_next()
	print("[%s] Found: %s" % [get_path().get_name(1), files])
	return files


func play_track(track_index: int) -> void:
	if track_index >= tracks.size():
		push_error("[%s] Track index %d is out of range. Max is %d" % [get_path().get_name(1), track_index, tracks.size()])
		return
	current_track = track_index
	var file_name = tracks[track_index]
	print("[%s] Playing track %d: %s " % [get_path().get_name(1), track_index, file_name])
	self.stream = load(music_file_path + file_name)
	self.play()


func play_next_track() -> void:
	var next_track = current_track + 1
	# Make sure it's a value in the array
	next_track %= tracks.size()
	play_track(next_track)


func play_random_track() -> void:
	var rand_track = randi() % tracks.size()
	if rand_track == current_track:
		play_next_track()
	else:
		play_track(rand_track)


func play_track_name(track_name: String) -> void:
	var index = tracks.find(track_name)
	if index == -1:
		push_error("[%s] Cannot find track named: %s" % [get_path().get_name(1), track_name])
		return
	play_track(index)


func _on_MusicPlayer_finished():
	print("[%s] Finished track %d: %s" % [get_path().get_name(1), current_track, tracks[current_track]])
	play_next_track()
