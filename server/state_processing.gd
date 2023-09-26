extends Node

const CLIENT_FPS = 60
const SERVER_FPS = 60
const TICKS_PER_FPS = CLIENT_FPS / SERVER_FPS

var server: ServerNetwork
var tick := 0
var world_state := {}
var running := false setget set_running


func _ready() -> void:
	server = get_parent()
	if not server:
		push_error("StateProcessing must have a ServerNetwork as a parent!")


func _physics_process(_delta: float) -> void:
	if not running:
		return
	tick += 1
	if tick >= TICKS_PER_FPS:
		tick = 0
		process_world_state()


func set_running(value: bool) -> void:
	running = value
	if running:
		Logger.print(self, "StateProcessing started running!")
	else:
		Logger.print(self, "StateProcessing stopped running!")


func process_world_state() -> void:
	if not server.player_state_collection.empty():
		world_state = server.player_state_collection.duplicate(true)
		# print_debug(world_state)
		for player_id in world_state.keys():
			world_state[player_id].erase("T")
			if has_node("../World/" + str(player_id)):
				var player := get_node("../World/" + str(player_id))
				# Don't move bots as it will result in a loop of setting the same position
				if not player.is_bot:
					player.move_player(world_state[player_id]["P"], world_state[player_id]["V"])
		# This will help client determine how old the received world_state is
		world_state["T"] = OS.get_system_time_msecs()
		# TODO: add anti-cheat here
		server.send_world_state(world_state)
