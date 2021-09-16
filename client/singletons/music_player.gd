extends AudioStreamPlayer

var music_file_path := "res://client/music/"
var supported_filetypes := ["ogg"]
var tracks := []
var current_track := 0
var current_track_name := ""


func _ready() -> void:
	tracks = load_music(music_file_path)


func load_music(path: String) -> Array:
	Logger.print(self, "Loading music files")
	var files := []
	var dir = Directory.new()
	if dir.open(path) != OK:
		push_error("An error occurred when trying to access the path: %s" % [path])
		return []

	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if supported_filetypes.has(file_name.get_extension()):
			files.append(file_name)
		file_name = dir.get_next()
	Logger.print(self, "Found: %s" % [files])
	return files


func play_track(track_index: int) -> void:
	if track_index >= tracks.size():
		push_error("Track index %d is out of range. Max is %d" % [track_index, tracks.size()])
		return
	var file_name = tracks[track_index]
	Logger.print(self, "Playing track %d: %s " % [track_index, file_name])
	self.stream = load(music_file_path + file_name)
	self.play()
	current_track = track_index
	current_track_name = file_name


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
		push_error("Cannot find track named: %s" % [track_name])
		return
	play_track(index)


func _on_MusicPlayer_finished() -> void:
	Logger.print(self, "Finished track %d: %s" % [current_track, tracks[current_track]])
	play_next_track()
