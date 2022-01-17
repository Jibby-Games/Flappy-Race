extends Node

# This node is only needed to detect the command line args so the right scene can be loaded
func _ready() -> void:
	if "--server" in OS.get_cmdline_args():
		Network.change_to_server()
	else:
		Globals.change_to_client()
		Network.change_to_client()
