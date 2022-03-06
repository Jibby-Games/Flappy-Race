extends Node


const HIGH_SCORE_FNAME := "user://highscore.save"
const RESOLUTIONS := [
	Vector2(1366, 768),
	Vector2(1600, 900),
	Vector2(1920, 1080),
	Vector2(2560, 1440),
	Vector2(3840, 2160)
]


# Game Settings
var high_score: int = 0 setget set_highscore
var player_colour: int = 0 setget set_player_colour
var player_name: String = "Flappo" setget set_player_name


# Audio Settings
var default_master_volume: float = 1.0
var default_music_volume: float = 0.8
var default_sounds_volume: float = 0.8
var master_volume: float = 1.0 setget set_master_volume
var music_volume: float = 0.8 setget set_music_volume
var sounds_volume: float = 0.8 setget set_sounds_volume

var master_bus_index = AudioServer.get_bus_index("Master")
var music_bus_index = AudioServer.get_bus_index("Music")
var sounds_bus_index = AudioServer.get_bus_index("Sounds")

var default_master_linear_db = db2linear(AudioServer.get_bus_volume_db(master_bus_index))
var default_music_linear_db = db2linear(AudioServer.get_bus_volume_db(music_bus_index))
var default_sounds_linear_db = db2linear(AudioServer.get_bus_volume_db(sounds_bus_index))

# These offsets anchor the volume around the default audio bus values
# E.g. 100% = -6db
var master_offset = default_master_volume - default_master_linear_db
var music_offset = default_music_volume - default_music_linear_db
var sounds_offset = default_sounds_volume - default_sounds_linear_db


# Video Settings
var default_resolution: Vector2 = Vector2(
	ProjectSettings.get_setting("display/window/size/width"),
	ProjectSettings.get_setting("display/window/size/height")
)
var resolution: Vector2 = default_resolution setget set_resolution
var fullscreen: bool = false setget set_fullscreen
var vsync: bool = true setget set_vsync


func _ready() -> void:
	high_score = load_high_score()


func load_high_score() -> int:
	var save_file = File.new()
	if not save_file.file_exists(HIGH_SCORE_FNAME):
		return 0

	save_file.open(HIGH_SCORE_FNAME, File.READ)
	var data = parse_json(save_file.get_as_text())
	save_file.close()

	# JSON parsing returns numbers as floats by default
	var score = data['highscore']
	if score and score is float:
		Logger.print(self, "Loaded high score: %s", [score])
		return int(score)
	else:
		reset_high_score()
		return 0


func save_high_score(score: int) -> void:
	high_score = score
	var save_file = File.new()
	save_file.open(HIGH_SCORE_FNAME, File.WRITE)

	# We will store as a JSON object. Overkill for a single integer, but should
	# be easy to scale out.
	var store_dict = {"highscore": score}

	save_file.store_line(to_json(store_dict))
	save_file.close()


func reset_high_score() -> void:
	save_high_score(0)
	Logger.print(self, "Reset highscore to 0")


func set_highscore(value: int) -> void:
	save_high_score(value)


func set_player_colour(value: int) -> void:
	player_colour = value


func set_player_name(value: String) -> void:
	player_name = value


func set_master_volume(value: float) -> void:
	master_volume = value
	AudioServer.set_bus_volume_db(
		master_bus_index,
		linear2db(value-master_offset)
	)


func set_music_volume(value: float) -> void:
	music_volume = value
	AudioServer.set_bus_volume_db(
		music_bus_index,
		linear2db(value-music_offset)
	)


func set_sounds_volume(value: float) -> void:
	sounds_volume = value
	AudioServer.set_bus_volume_db(
		sounds_bus_index,
		linear2db(value-sounds_offset)
	)


func set_resolution(value: Vector2) -> void:
	resolution = value
	OS.window_size = value


func set_fullscreen(value: bool) -> void:
	fullscreen = value
	OS.window_fullscreen = value


func set_vsync(value: bool) -> void:
	vsync = value
	OS.vsync_enabled = value


func reset_settings() -> void:
	set_master_volume(default_master_volume)
	set_music_volume(default_music_volume)
	set_sounds_volume(default_sounds_volume)
	set_resolution(default_resolution)
	set_fullscreen(false)
	set_vsync(true)
	Logger.print(self, "Reset all settings to default")


func show_message(text: String, title: String='Message') -> void:
	var dialog = AcceptDialog.new()
	dialog.dialog_text = text
	dialog.window_title = title
	dialog.connect('popup_hide', dialog, 'queue_free')
	get_tree().get_root().add_child(dialog)
	dialog.popup_centered()
