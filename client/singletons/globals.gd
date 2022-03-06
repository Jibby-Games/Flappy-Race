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
var high_score: int = 0
var player_colour: int = 0
var player_name: String = "Flappo"


# Audio Settings
var default_master_volume: float = 1.0
var default_music_volume: float = 0.8
var default_sounds_volume: float = 0.8
var master_volume: float = 1.0
var music_volume: float = 0.8
var sounds_volume: float = 0.8


# Video Settings
var default_resolution: Vector2 = Vector2(
	ProjectSettings.get_setting("display/window/size/width"),
	ProjectSettings.get_setting("display/window/size/height")
)
var resolution: Vector2 = default_resolution
var fullscreen: bool = false
var vsync: bool = true


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


func show_message(text: String, title: String='Message') -> void:
	var dialog = AcceptDialog.new()
	dialog.dialog_text = text
	dialog.window_title = title
	dialog.connect('popup_hide', dialog, 'queue_free')
	get_tree().get_root().add_child(dialog)
	dialog.popup_centered()
