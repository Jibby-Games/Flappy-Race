extends MenuControl


export(NodePath) var master_slider_path
export(NodePath) var master_percent_path
export(NodePath) var music_slider_path
export(NodePath) var music_percent_path
export(NodePath) var sounds_slider_path
export(NodePath) var sounds_percent_path
export(NodePath) var resolution_options_path
export(NodePath) var fullscreen_button_path
export(NodePath) var vsync_button_path


onready var master_slider = get_node(master_slider_path)
onready var master_percent = get_node(master_percent_path)
onready var music_slider = get_node(music_slider_path)
onready var music_percent = get_node(music_percent_path)
onready var sounds_slider = get_node(sounds_slider_path)
onready var sounds_percent = get_node(sounds_percent_path)
onready var resolution_options = get_node(resolution_options_path)
onready var fullscreen_button = get_node(fullscreen_button_path)
onready var vsync_button = get_node(vsync_button_path)


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


func _ready() -> void:
	# Load options

	# Add all resolutions
	for i in Globals.RESOLUTIONS.size():
		var res_item := "%sx%s" % [Globals.RESOLUTIONS[i].x, Globals.RESOLUTIONS[i].y]
		resolution_options.add_item(res_item)
		# Select current resolution
		if Globals.RESOLUTIONS[i] == Globals.resolution:
			resolution_options.select(i)
	fullscreen_button.pressed = Globals.fullscreen
	vsync_button.pressed = Globals.vsync

	# Audio
	master_slider.set_value(Globals.master_volume)
	master_percent.set_text(float2percent(Globals.master_volume))
	music_slider.set_value(Globals.music_volume)
	music_percent.set_text(float2percent(Globals.music_volume))
	sounds_slider.set_value(Globals.sounds_volume)
	sounds_percent.set_text(float2percent(Globals.sounds_volume))

	# Only connect the signal after to stop the inital set_value from firing it
	sounds_slider.connect("value_changed", self, "_on_SoundsSlider_value_changed")
	resolution_options.connect("item_selected", self, "_on_ResolutionOptionButton_item_selected")
	fullscreen_button.connect("toggled", self, "_on_FullscreenCheckButton_toggled")
	vsync_button.connect("toggled", self, "_on_VsyncCheckButton_toggled")


func _on_BackButton_pressed() -> void:
	change_menu_to_previous()


func _on_MasterSlider_value_changed(value: float) -> void:
	Globals.master_volume = value
	master_percent.set_text(float2percent(value))
	AudioServer.set_bus_volume_db(
		master_bus_index,
		linear2db(value-master_offset)
	)


func _on_MusicSlider_value_changed(value: float) -> void:
	Globals.music_volume = value
	music_percent.set_text(float2percent(value))
	AudioServer.set_bus_volume_db(
		music_bus_index,
		linear2db(value-music_offset)
	)


func _on_SoundsSlider_value_changed(value: float) -> void:
	Globals.sounds_volume = value
	sounds_percent.set_text(float2percent(value))
	AudioServer.set_bus_volume_db(
		sounds_bus_index,
		linear2db(value-sounds_offset)
	)
	$SoundsVolumeTester.play()


func _on_FullscreenCheckButton_toggled(button_pressed: bool) -> void:
	Globals.fullscreen = button_pressed
	OS.window_fullscreen = button_pressed


func _on_ResolutionOptionButton_item_selected(index: int) -> void:
	Globals.resolution = Globals.RESOLUTIONS[index]
	OS.window_size = Globals.RESOLUTIONS[index]


func _on_VsyncCheckButton_toggled(button_pressed: bool) -> void:
	Globals.vsync = button_pressed
	OS.vsync_enabled = button_pressed
