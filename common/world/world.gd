extends Node2D


class_name CommonWorld


export(PackedScene) var Player


const STARTING_JUMP := 500


var game_rng := RandomNumberGenerator.new()
var game_options := {} setget set_game_options

# Dictionary of all players in the current game
# Includes player preferences and a reference to the player body if playing
var player_list := {}
# Array of all spawned player bodies
var spawned_players := []

onready var level_generator = $LevelGenerator as LevelGenerator
onready var chunk_tracker = $ChunkTracker as ChunkTracker


func _ready() -> void:
	Logger.print(self, "World ready!")


# Randomises the current game RNG seed and returns it
func randomize_game_seed() -> int:
	game_rng.randomize()
	Logger.print(self, "Generated random seed: %d" % [game_rng.seed])
	return game_rng.seed


# Sets the game RNG seed
func set_game_seed(new_seed: int) -> void:
	game_rng.seed = new_seed
	Logger.print(self, "Set game seed to: %d" % [new_seed])


func set_game_options(new_game_options: Dictionary) -> void:
	game_options = new_game_options
	Logger.print(self, "Set game options to: %s" % [new_game_options])


func start_game(game_seed: int, new_game_options: Dictionary, new_player_list: Dictionary) -> void:
	Logger.print(self, "Starting game with seed = %d, game options: %s and players: %s" %
		[game_seed, new_game_options, new_player_list])
	set_game_seed(game_seed)
	set_game_options(new_game_options)
	self.player_list = new_player_list
	chunk_tracker.chunk_limit = game_options.goal
	level_generator.generate(game_rng, game_options.goal)


func _on_LevelGenerator_level_ready() -> void:
	reset_players()


func reset_players() -> void:
	# Delete all existing players
	for player in spawned_players:
		spawned_players.erase(player)
		player.queue_free()
	Logger.print(self, "Spawning players in list: %s" % [player_list])
	for player_id in player_list:
		var player_entry = player_list[player_id]
		player_entry.score = 0
		# Don't spawn any spectators
		if player_entry.spectate == true:
			continue
		var player_body := spawn_player(player_id, Vector2.ZERO)
		player_entry["body"] = player_body
		spawned_players.append(player_body)


func spawn_player(player_id: int, spawn_position: Vector2) -> Node2D:
	if not has_node(str(player_id)):
		Logger.print(self, "Spawning player %d" % [player_id])
		var player = Player.instance()
		player.connect("death", self, "_on_Player_death")
		player.connect("score_changed", self, "_on_Player_score_changed")
		player.connect("finish", self, "_on_Player_finish")
		player.name = str(player_id)
		player.position = spawn_position
		player.enable_movement = false
		add_child(player)
		return player
	return null


func despawn_player(player_id: int) -> void:
	Logger.print(self, "Despawning player %d" % [player_id])
	var player = get_node_or_null(str(player_id))
	if player:
		spawned_players.erase(player)
		player.despawn()
		if spawned_players.size() == 0:
			end_race()


func knockback_player(player_id: int) -> void:
	if player_list[player_id].spectate == false:
		var player = player_list[player_id].body as CommonPlayer
		player.knockback()


#### Player helper functions
func _on_Player_death(player: CommonPlayer) -> void:
	player.set_enable_movement(false)
	var player_id = int(player.name)
	Logger.print(self, "Player %s died at %s!" % [player_id, player.position])


func _on_Player_score_changed(player: CommonPlayer) -> void:
	var player_id = int(player.name)
	Logger.print(self, "Player %s scored a point!" % [player_id])
	chunk_tracker.increment_player_chunk(player_id)


func _on_Player_finish(player: CommonPlayer) -> void:
	var player_id = int(player.name)
	Logger.print(self, "Player %s crossed the finish line!" % player_id)
	despawn_player(player_id)


func end_race() -> void:
	Logger.print(self, "Race finished!")
