extends CommonWorld


const INTERPOLATION_OFFSET = 100


# World state vars
var last_world_state := 0
var world_state_buffer := []


var player_list := {}


func _ready() -> void:
	Network.Client.send_client_ready()


func _physics_process(_delta) -> void:
	var render_time = Network.Client.client_clock - INTERPOLATION_OFFSET
	if world_state_buffer.size() > 1:
		# world_state_buffer[0] will always be the oldest received world_state
		while world_state_buffer.size() > 2 and render_time > world_state_buffer[2].T:
			world_state_buffer.remove(0)
		if world_state_buffer.size() > 2:
			# We have a future world state available - smooth movement!
			interpolate_world_state(render_time)
		elif render_time > world_state_buffer[1].T:
			# No future world_states available - guess where things will be
			extrapolate_world_state(render_time)


func interpolate_world_state(render_time) -> void:
	var interpolation_factor = float(render_time - world_state_buffer[1]["T"]) / float(world_state_buffer[2]["T"] - world_state_buffer[1]["T"])
	for player in world_state_buffer[2].keys():
		if str(player) == "T":
			# Ignore the included timestamp
			continue
		if player == multiplayer.get_network_unique_id():
			# Ignore the local player
			continue
		if not world_state_buffer[1].has(player):
			# A connecting player won't be available in past world_state yet
			continue
		if has_node(str(player)):
			# Use the position between past and future world_states to calculate
			# the current position
			var new_position = lerp(
				world_state_buffer[1][player]["P"],
				world_state_buffer[2][player]["P"],
				interpolation_factor
			)
			get_node(str(player)).move_player(new_position)
		# TODO this should only spawn players if they are present in a future
		# world state but sometimes they still seem to arrive after death
		# else:
		# 	spawn_player(player, world_state_buffer[2][player]["P"])


func extrapolate_world_state(render_time) -> void:
	var extrapolation_factor = float(render_time - world_state_buffer[0]["T"]) / float(world_state_buffer[1]["T"] - world_state_buffer[0]["T"]) - 1.00
	for player in world_state_buffer[1].keys():
		if str(player) == "T":
			# Ignore the included timestamp
			continue
		if player == multiplayer.get_network_unique_id():
			# Ignore the local player
			continue
		if not world_state_buffer[0].has(player):
			# A connecting player won't be available in past world_state yet
			continue
		if has_node(str(player)):
			var position_delta = (world_state_buffer[1][player]["P"] - world_state_buffer[0][player]["P"])
			var new_position = world_state_buffer[1][player]["P"] + (position_delta * extrapolation_factor)
			get_node(str(player)).move_player(new_position)


func update_world_state(world_state) -> void:
	if world_state["T"] > last_world_state:
		last_world_state = world_state["T"]
		world_state_buffer.append(world_state)


func start_game(game_seed: int) -> void:
	.start_game(game_seed)
	# Spawn the local client player
	var local_player = multiplayer.get_network_unique_id()
	spawn_player(local_player, Vector2.ZERO, true)


func reset_game() -> void:
	Network.Client.send_start_game_request()


func spawn_player(player_id: int, spawn_position: Vector2, is_controllable: bool = false) -> void:
	.spawn_player(player_id, spawn_position, is_controllable)
	var player = get_node(str(player_id))
	player.set_body_colour(player_list[player_id]["colour"])
	player.set_player_name(player_list[player_id]["name"])


func despawn_player(player_id: int):
	# If this is the local player show the game over UI
	if player_id == multiplayer.get_network_unique_id():
		$UI.show_game_over()
	.despawn_player(player_id)


func _on_Player_death(player) -> void:
	# If this is the local player show the game over UI
	if int(player.name) == multiplayer.get_network_unique_id():
		$UI.show_game_over()
	._on_Player_death(player)


func _on_Player_score_point(player) -> void:
	$UI.update_score(player.score)
	._on_Player_score_point(player)


func _on_BGMusic_finished() -> void:
	$BGMusic.play()


func _on_UI_request_restart():
	reset_game()
