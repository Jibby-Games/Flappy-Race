extends Node

const HIGH_SCORE_FNAME := "user://highscore.save"
const SETTINGS_FILE_PATH := "user://settings.cfg"
const RESOLUTIONS := [
	Vector2(1366, 768),
	Vector2(1600, 900),
	Vector2(1920, 1080),
	Vector2(2560, 1440),
	Vector2(3840, 2160)
]
const DEFAULT_SETTINGS := {
	"master_volume": 1.0,
	"music_volume": 0.8,
	"sounds_volume": 0.8,
	"resolution": Vector2(1920, 1080),
	"fullscreen": false,
	"vsync": true
}

# Colour palette by PineappleOnPizza: https://lospec.com/palette-list/bubblegum-16
const COLOUR_OPTIONS: PoolColorArray = PoolColorArray(
	[
		"#d62411",
		"#7f0622",
		"#ff8426",
		"#ffd100",
		"#ff80a4",
		"#ff2674",
		"#94216a",
		"#430067",
		"#234975",
		"#68aed4",
		"#bfff3c",
		"#10d275",
		"#007899",
		"#002859",
		"#fafdff",
		"#16171a",
	]
)

# Settings
var high_score: int = 0 setget set_highscore
var player_colour: int = 0 setget set_player_colour
var player_name: String = "Flappo" setget set_player_name
var settings := {}

# Audio vars
var master_bus_index = AudioServer.get_bus_index("Master")
var music_bus_index = AudioServer.get_bus_index("Music")
var sounds_bus_index = AudioServer.get_bus_index("Sounds")

# These ratios anchor the volume around the default audio bus values e.g. 100% = -2.6db
var master_volume_ratio = (
	db2linear(AudioServer.get_bus_volume_db(master_bus_index))
	/ DEFAULT_SETTINGS.master_volume
)
var music_volume_ratio = (
	db2linear(AudioServer.get_bus_volume_db(music_bus_index))
	/ DEFAULT_SETTINGS.music_volume
)
var sounds_volume_ratio = (
	db2linear(AudioServer.get_bus_volume_db(sounds_bus_index))
	/ DEFAULT_SETTINGS.sounds_volume
)


func _ready() -> void:
	high_score = load_high_score()
	var loaded_settings = load_settings()
	apply_settings(loaded_settings)


func load_high_score() -> int:
	var save_file = File.new()
	if not save_file.file_exists(HIGH_SCORE_FNAME):
		return 0

	save_file.open(HIGH_SCORE_FNAME, File.READ)
	var data = parse_json(save_file.get_as_text())
	save_file.close()

	# JSON parsing returns numbers as floats by default
	var score = data["highscore"]
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


func save_settings(new_settings: Dictionary) -> void:
	var settings_file = ConfigFile.new()
	for setting in DEFAULT_SETTINGS.keys():
		# Ensure only the settings defined in the default settings are saved
		var value = (
			new_settings[setting]
			if new_settings.has(setting)
			else DEFAULT_SETTINGS[setting]
		)
		settings_file.set_value("settings", setting, value)
	settings_file.save(SETTINGS_FILE_PATH)
	Logger.print(self, "Saved settings: %s", [new_settings])


func load_settings() -> Dictionary:
	var settings_file = ConfigFile.new()
	var result = settings_file.load(SETTINGS_FILE_PATH)
	if result != OK or settings_file.has_section("settings") == false:
		Logger.print(self, "Failed to load settings file, using defaults")
		return DEFAULT_SETTINGS.duplicate()

	# Loops through the defaults and loads each value
	# Fallsback to the default value if it doesn't exist
	var new_settings = {}
	for setting in DEFAULT_SETTINGS.keys():
		new_settings[setting] = settings_file.get_value(
			"settings", setting, DEFAULT_SETTINGS[setting]
		)

	Logger.print(self, "Loaded settings: %s", [new_settings])
	return new_settings


func apply_settings(new_settings: Dictionary) -> void:
	# Audio
	set_master_volume(new_settings.master_volume)
	set_music_volume(new_settings.music_volume)
	set_sounds_volume(new_settings.sounds_volume)

	# Graphics
	set_fullscreen(new_settings.fullscreen)
	set_resolution(new_settings.resolution)
	set_vsync(new_settings.vsync)


func reset_settings() -> void:
	settings = DEFAULT_SETTINGS.duplicate()
	apply_settings(settings)
	Logger.print(self, "Reset all settings to default: %s", [settings])


func set_player_colour(value: int) -> void:
	player_colour = value


func set_player_name(value: String) -> void:
	player_name = value


func set_master_volume(value: float) -> void:
	settings.master_volume = value
	AudioServer.set_bus_volume_db(master_bus_index, linear2db(value * master_volume_ratio))


func set_music_volume(value: float) -> void:
	settings.music_volume = value
	AudioServer.set_bus_volume_db(music_bus_index, linear2db(value * music_volume_ratio))


func set_sounds_volume(value: float) -> void:
	settings.sounds_volume = value
	AudioServer.set_bus_volume_db(sounds_bus_index, linear2db(value * sounds_volume_ratio))


func set_resolution(value: Vector2) -> void:
	settings.resolution = value
	OS.window_size = value


func set_fullscreen(value: bool) -> void:
	settings.fullscreen = value
	OS.window_fullscreen = value


func set_vsync(value: bool) -> void:
	settings.vsync = value
	OS.vsync_enabled = value


func show_message(text: String, title: String = "Message") -> void:
	var dialog = AcceptDialog.new()
	dialog.dialog_text = text
	dialog.window_title = title
	dialog.connect("popup_hide", dialog, "queue_free")
	get_tree().get_root().add_child(dialog)
	dialog.popup_centered()


func get_random_colour_id() -> int:
	return randi() % Globals.COLOUR_OPTIONS.size()
