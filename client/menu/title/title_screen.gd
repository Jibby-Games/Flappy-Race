extends MenuControl

var singleplayer_scene := "res://client/menu/setup/singleplayer/singleplayer_setup.tscn"
var multiplayer_scene := "res://client/menu/lobby/name_entry.tscn"
var options_scene := "res://client/menu/options/options.tscn"
var title_player := preload("res://client/menu/title/title_player.tscn")
# Aim for about 16 players
var area_per_player := (1920 * 1080) / 16
var spawned_title_players := []


func _ready() -> void:
	$Menu/VersionLabel.text = ProjectSettings.get_setting("application/config/version")
	$Menu/Buttons/SingleplayerButton.grab_focus()
	var result := get_viewport().connect("size_changed", self, "spawn_title_players")
	assert(result == OK)
	spawn_title_players()
	if OS.has_feature("web"):
		$Menu/Buttons/SingleplayerButton.hide()


func spawn_title_players() -> void:
	if not is_inside_tree():
		# Scene might not be fully loaded if using command line args to join
		return
	var total_players := get_viewport_rect().get_area() / area_per_player
	Logger.print(self, "Viewport size changed - Need %d players" % total_players)
	if total_players > spawned_title_players.size():
		# Add more players
		var players_to_spawn := total_players - spawned_title_players.size()
		Logger.print(self, "Spawning %d players" % players_to_spawn)
		for i in players_to_spawn:
			var inst = title_player.instance()
			spawned_title_players.append(inst)
			$PlayerContainer.add_child(inst)
	elif total_players < spawned_title_players.size():
		# Remove some players
		var players_to_despawn := spawned_title_players.size() - total_players
		Logger.print(self, "Removing %d players" % players_to_despawn)
		for i in players_to_despawn:
			var player = spawned_title_players.pop_back()
			player.remove_when_off_screen = true


func _on_SingleplayerButton_pressed() -> void:
	change_menu(singleplayer_scene)
	Network.start_singleplayer()


func _on_MultiplayerButton_pressed() -> void:
	change_menu(multiplayer_scene)


func _on_OptionsButton_pressed() -> void:
	change_menu(options_scene)


func _on_QuitButton_pressed() -> void:
	get_tree().notification(MainLoop.NOTIFICATION_WM_QUIT_REQUEST)
