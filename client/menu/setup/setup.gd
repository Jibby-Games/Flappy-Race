extends MenuControl

var title_scene := "res://client/menu/title/title_screen.tscn"
var server_browser_scene := "res://client/menu/lobby/server_browser.tscn"

onready var colour_selector := $PlayerOptions/Control/ColourSelector
onready var player := $PlayerOptions/Control/Player
onready var player_list = $PlayerList
onready var info_message = $InfoMessage

const SPECTATE_BUTTON_Y_SPECTATING := 575
const SPECTATE_BUTTON_Y_PLAYING := 695

var is_spectating = false
var is_ready = false

func _ready() -> void:
	# Disable the player physics so it doesn't fall
	player.set_physics_process(false)

	# Create the colour selector
	colour_selector.generate_swatches(Globals.COLOUR_OPTIONS)

	# Set the saved player colour
	player.set_body_colour(Globals.player_colour)
	colour_selector.select(Globals.player_colour)

	# Update for any player list, host or game option changes
	var result: int
	result = Network.Client.connect("player_list_changed", self, "populate_players")
	assert(result == OK)
	result = Network.Client.connect("host_changed", self, "_on_host_changed")
	assert(result == OK)
	result = Network.Client.connect("game_options_changed", self, "_on_game_options_changed")
	assert(result == OK)

	info_message.hide()

	if Network.Client.is_server_connected():
		# Already connected to the server, so set all of the values
		set_enable_host_options(Network.Client.is_host())
		if not Network.Client.game_options.empty():
			$GameOptions.set_game_options(Network.Client.game_options)
		if not Network.Client.player_list.empty():
			populate_players({}, Network.Client.player_list)
			var player_id = multiplayer.get_network_unique_id()
			if Network.Client.late_joined:
				# Disable spectating automatically for late joiners
				set_is_spectating(false)
				Network.Client.send_player_spectate_change(is_spectating)
			else:
				set_is_spectating(Network.Client.player_list[player_id].spectate)

	# Need to defer this or the menu animation hides it
	$StartButton.call_deferred("grab_focus")


func _on_host_changed(_old_host_id: int, _new_host: int) -> void:
	var is_host := Network.Client.is_host()
	set_enable_host_options(is_host)
	if (not Network.Client.is_singleplayer) and is_host:
		show_message("You're the new host!")


func set_is_spectating(value: bool) -> void:
	is_spectating = value
	$SpectatorText.visible = is_spectating
	$PlayerOptions.visible = not is_spectating
	$SpectateButton.text = "Join Game" if is_spectating else "Spectate"
	$SpectateButton.hint_tooltip = "Become a player" if is_spectating else "Become a spectator"
	$SpectateButton.rect_position.y = SPECTATE_BUTTON_Y_SPECTATING if is_spectating else SPECTATE_BUTTON_Y_PLAYING


func show_message(message: String) -> void:
	info_message.text = message
	var animation = info_message.get_node("AnimationPlayer")
	animation.stop()
	animation.play("show")


func _on_game_options_changed(new_game_options: Dictionary) -> void:
	$GameOptions.set_game_options(new_game_options)


func set_enable_host_options(is_host: bool) -> void:
	$StartButton.visible = is_host
	$GameOptions.set_enable_host_options(is_host)
	$IpFinder.visible = ((not Network.Client.is_singleplayer) and Network.is_server_hosting())
	$GameIdInfo.game_id = Network.Client.game_id
	$GameIdInfo.visible = ((not Network.Client.is_singleplayer) and not Network.Client.game_id.empty())
	$ReadyButton.visible = not is_host


func populate_players(_old_player_list: Dictionary, new_player_list: Dictionary) -> void:
	Logger.print(self, "Got player list: %s" % [new_player_list])
	player_list.clear_players()
	$GameOptions.set_max_bots(Network.MAX_PLAYERS - multiplayer.get_network_connected_peers().size())
	for player_id in new_player_list:
		var colour_choice = new_player_list[player_id]["colour"]
		var player_name = new_player_list[player_id]["name"]
		var spectating = new_player_list[player_id]["spectate"]
		var is_bot = new_player_list[player_id]["bot"]
		var player_ready = new_player_list[player_id]["ready"]
		player_list.add_player(
			player_id,
			player_name,
			colour_choice,
			spectating,
			is_bot,
			player_ready
		)


func update_player_colour(player_id: int, colour_choice: int) -> void:
	player_list.update_player_colour(player_id, colour_choice)


func update_player_spectating(player_id: int, _is_spectating: bool) -> void:
	player_list.update_player_spectating(player_id, _is_spectating)


func update_player_ready(player_id: int, _is_ready: bool) -> void:
	player_list.update_player_ready(player_id, _is_ready)
	if player_id == multiplayer.get_network_unique_id():
		$ReadyButton.set_pressed_no_signal(_is_ready)


func _on_BackButton_pressed() -> void:
	Network.stop_networking()
	if Network.Client.is_singleplayer:
		change_menu(title_scene)
	else:
		change_menu(server_browser_scene)


func _on_StartButton_pressed() -> void:
	Network.Client.send_start_game_request()


func _on_ColourSelector_colour_changed(new_value: int) -> void:
	if new_value != Globals.player_colour:
		Globals.player_colour = new_value
		player.set_body_colour(new_value)
		Network.Client.send_player_colour_change(new_value)


func _on_SpectateButton_pressed() -> void:
	set_is_spectating(not is_spectating)
	Network.Client.send_player_spectate_change(is_spectating)


func _on_ReadyButton_toggled(button_pressed: bool) -> void:
	is_ready = button_pressed
	player_list.update_player_ready(multiplayer.get_network_unique_id(), is_ready)
	Network.Client.send_player_ready_change(is_ready)
