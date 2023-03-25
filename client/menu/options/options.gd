extends MenuControl

var title_scene := "res://client/menu/title/title_screen.tscn"

export(NodePath) var master_slider_path
export(NodePath) var master_percent_path
export(NodePath) var music_slider_path
export(NodePath) var music_percent_path
export(NodePath) var sounds_slider_path
export(NodePath) var sounds_percent_path
export(NodePath) var resolution_options_path
export(NodePath) var fullscreen_button_path
export(NodePath) var vsync_button_path
export(NodePath) var high_score_label_path

onready var master_slider = get_node(master_slider_path)
onready var master_percent = get_node(master_percent_path)
onready var music_slider = get_node(music_slider_path)
onready var music_percent = get_node(music_percent_path)
onready var sounds_slider = get_node(sounds_slider_path)
onready var sounds_percent = get_node(sounds_percent_path)
onready var resolution_options = get_node(resolution_options_path)
onready var fullscreen_button = get_node(fullscreen_button_path)
onready var vsync_button = get_node(vsync_button_path)
onready var high_score_label = get_node(high_score_label_path)


func float2percent(value: float) -> String:
	return "%s%%" % str(value * 100)


func _ready() -> void:
	# Add all resolutions as options
	for i in Globals.RESOLUTIONS.size():
		var res_item := "%sx%s" % [Globals.RESOLUTIONS[i].x, Globals.RESOLUTIONS[i].y]
		resolution_options.add_item(res_item)

	load_all_settings()

	# Only connect the signal after to stop the inital set_value from firing it
	master_slider.connect("value_changed", self, "_on_MasterSlider_value_changed")
	music_slider.connect("value_changed", self, "_on_MusicSlider_value_changed")
	sounds_slider.connect("value_changed", self, "_on_SoundsSlider_value_changed")
	resolution_options.connect("item_selected", self, "_on_ResolutionOptionButton_item_selected")
	fullscreen_button.connect("toggled", self, "_on_FullscreenCheckButton_toggled")
	vsync_button.connect("toggled", self, "_on_VsyncCheckButton_toggled")


func load_all_settings() -> void:
	# Graphics
	var res_index = Globals.RESOLUTIONS.find(Globals.settings.resolution)
	if res_index != -1:
		resolution_options.select(res_index)
	fullscreen_button.pressed = Globals.settings.fullscreen
	vsync_button.pressed = Globals.settings.vsync

	# Audio
	master_slider.set_value(Globals.settings.master_volume)
	master_percent.set_text(float2percent(Globals.settings.master_volume))
	music_slider.set_value(Globals.settings.music_volume)
	music_percent.set_text(float2percent(Globals.settings.music_volume))
	sounds_slider.set_value(Globals.settings.sounds_volume)
	sounds_percent.set_text(float2percent(Globals.settings.sounds_volume))

	# Gameplay
	high_score_label.set_text(str(Globals.high_score))


func _on_BackButton_pressed() -> void:
	Globals.save_settings(Globals.settings)
	change_menu(title_scene)


func _on_MasterSlider_value_changed(value: float) -> void:
	Globals.set_master_volume(value)
	master_percent.set_text(float2percent(value))


func _on_MusicSlider_value_changed(value: float) -> void:
	Globals.set_music_volume(value)
	music_percent.set_text(float2percent(value))


func _on_SoundsSlider_value_changed(value: float) -> void:
	Globals.set_sounds_volume(value)
	sounds_percent.set_text(float2percent(value))
	$SoundsVolumeTester.play()


func _on_FullscreenCheckButton_toggled(button_pressed: bool) -> void:
	Globals.set_fullscreen(button_pressed)


func _on_ResolutionOptionButton_item_selected(index: int) -> void:
	Globals.set_resolution(Globals.RESOLUTIONS[index])


func _on_VsyncCheckButton_toggled(button_pressed: bool) -> void:
	Globals.set_vsync(button_pressed)


func _on_ResetHighScoreButton_pressed() -> void:
	Globals.reset_high_score()
	high_score_label.set_text(str(Globals.high_score))


func _on_ResetButton_pressed() -> void:
	Globals.reset_settings()
	load_all_settings()
