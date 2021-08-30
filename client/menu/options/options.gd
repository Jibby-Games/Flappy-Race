extends Control


onready var master_slider = $CenterContainer/VBoxContainer/MasterVolume/MasterSlider
onready var master_percent = $CenterContainer/VBoxContainer/MasterVolume/Percent
onready var music_slider = $CenterContainer/VBoxContainer/MusicVolume/MusicSlider
onready var music_percent = $CenterContainer/VBoxContainer/MusicVolume/Percent
onready var sounds_slider = $CenterContainer/VBoxContainer/SoundsVolume/SoundsSlider
onready var sounds_percent = $CenterContainer/VBoxContainer/SoundsVolume/Percent


var master_bus_index = AudioServer.get_bus_index("Master")
var music_bus_index = AudioServer.get_bus_index("Music")
var sounds_bus_index = AudioServer.get_bus_index("Sounds")

var default_master_linear_db = db2linear(AudioServer.get_bus_volume_db(master_bus_index))
var default_music_linear_db = db2linear(AudioServer.get_bus_volume_db(music_bus_index))
var default_sounds_linear_db = db2linear(AudioServer.get_bus_volume_db(sounds_bus_index))

# These offsets anchor the volume around the default audio bus values
# E.g. 100% = -6db
var master_offset = Globals.default_master_volume - default_master_linear_db
var music_offset = Globals.default_music_volume - default_music_linear_db
var sounds_offset = Globals.default_sounds_volume - default_sounds_linear_db


func float2percent(value: float) -> String:
	return "%s%%" % str(value*100)


func _ready():
	# Load options
	master_slider.set_value(Globals.master_volume)
	master_percent.set_text(float2percent(Globals.master_volume))
	music_slider.set_value(Globals.music_volume)
	music_percent.set_text(float2percent(Globals.music_volume))
	sounds_slider.set_value(Globals.sounds_volume)
	sounds_percent.set_text(float2percent(Globals.sounds_volume))
	# Only connect the signal after to stop the inital set_value from firing it
	sounds_slider.connect("value_changed", self, "_on_SoundsSlider_value_changed")


func _on_Button_pressed():
	Network.Client.change_scene("res://client/menu/title/title_screen.tscn")


func _on_MasterSlider_value_changed(value):
	Globals.master_volume = value
	master_percent.set_text(float2percent(value))
	AudioServer.set_bus_volume_db(
		master_bus_index,
		linear2db(value-master_offset)
	)


func _on_MusicSlider_value_changed(value):
	Globals.music_volume = value
	music_percent.set_text(float2percent(value))
	AudioServer.set_bus_volume_db(
		music_bus_index,
		linear2db(value-music_offset)
	)


func _on_SoundsSlider_value_changed(value):
	Globals.sounds_volume = value
	sounds_percent.set_text(float2percent(value))
	AudioServer.set_bus_volume_db(
		sounds_bus_index,
		linear2db(value-sounds_offset)
	)
	$SoundsVolumeTester.play()
