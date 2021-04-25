extends Node

const CLIENT_FPS = 60
const SERVER_FPS = 20
const TICKS_PER_FPS = CLIENT_FPS / SERVER_FPS

var Server : ServerNetwork
var tick := 0
var world_state := {}


func _ready() -> void:
	Server = get_parent()
	if not Server:
		push_error("StateProcessing must have a ServerNetwork as a parent!")


func _physics_process(_delta) -> void:
	tick += 1
	if tick >= TICKS_PER_FPS:
		tick = 0
		process_world_state()


func process_world_state() -> void:
	if not Server.player_state_collection.empty():
		world_state = Server.player_state_collection.duplicate(true)
		for player in world_state.keys():
			world_state[player].erase("T")
		# This will help client determine how old the received world_state is
		world_state["T"] = OS.get_system_time_msecs()
		# TODO: add anti-cheat here
		Server.send_world_state(world_state)
