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
	return "%s%%" % str(value*100)


func _ready() -> void:
	# Add all resolutions as options
	for i in Globals.RESOLUTIONS.size():
		var res_item := "%sx%s" % [Globals.RESOLUTIONS[i].x, Globals.RESOLUTIONS[i].y]
		resolution_options.add_item(res_item)

	load_all_settings()

	# Only connect the signal after to stop the inital set_value from firing it
	resolution_options.connect("item_selected", self, "_on_ResolutionOptionButton_item_selected")
	fullscreen_button.connect("toggled", self, "_on_FullscreenCheckButton_toggled")
	vsync_button.connect("toggled", self, "_on_VsyncCheckButton_toggled")


func load_all_settings() -> void:

	# Disconnect signals to stop value changed firing
	if sounds_slider.is_connected("value_changed", self, "_on_SoundsSlider_value_changed"):
		sounds_slider.disconnect("value_changed", self, "_on_SoundsSlider_value_changed")

	# Graphics
	var res_index = Globals.RESOLUTIONS.find(Globals.resolution)
	if res_index != -1:
		resolution_options.select(res_index)
	fullscreen_button.pressed = Globals.fullscreen
	vsync_button.pressed = Globals.vsync

	# Audio
	master_slider.set_value(Globals.master_volume)
	master_percent.set_text(float2percent(Globals.master_volume))
	music_slider.set_value(Globals.music_volume)
	music_percent.set_text(float2percent(Globals.music_volume))
	sounds_slider.set_value(Globals.sounds_volume)
	sounds_percent.set_text(float2percent(Globals.sounds_volume))

	# Gameplay
	high_score_label.set_text(str(Globals.high_score))

	# Reconnect signals again
	sounds_slider.connect("value_changed", self, "_on_SoundsSlider_value_changed")


func _on_BackButton_pressed() -> void:
	change_menu_to_previous()


func _on_MasterSlider_value_changed(value: float) -> void:
	Globals.master_volume = value
	master_percent.set_text(float2percent(value))


func _on_MusicSlider_value_changed(value: float) -> void:
	Globals.music_volume = value
	music_percent.set_text(float2percent(value))


func _on_SoundsSlider_value_changed(value: float) -> void:
	Globals.sounds_volume = value
	sounds_percent.set_text(float2percent(value))
	$SoundsVolumeTester.play()


func _on_FullscreenCheckButton_toggled(button_pressed: bool) -> void:
	Globals.fullscreen = button_pressed


func _on_ResolutionOptionButton_item_selected(index: int) -> void:
	Globals.resolution = Globals.RESOLUTIONS[index]


func _on_VsyncCheckButton_toggled(button_pressed: bool) -> void:
	Globals.vsync = button_pressed


func _on_ResetHighScoreButton_pressed() -> void:
	Globals.reset_high_score()
	high_score_label.set_text(str(Globals.high_score))


func _on_ResetButton_pressed() -> void:
	Globals.reset_settings()
	load_all_settings()
