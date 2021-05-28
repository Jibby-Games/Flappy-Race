extends Node

# This node is only needed to detect the command line args so the right scene can be loaded
func _ready():
	if "--server" in OS.get_cmdline_args():
		assert(get_tree().change_scene(Network.SERVER_NETWORK) == OK)
	else:
		assert(get_tree().change_scene(Network.CLIENT_NETWORK) == OK)
