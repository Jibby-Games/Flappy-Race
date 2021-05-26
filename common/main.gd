extends Node


export(PackedScene) var ClientMainScene
export(PackedScene) var ServerMainScene


func _ready():
	if "--server" in OS.get_cmdline_args():
		Network.Server.change_scene_to(ServerMainScene)
	else:
		Network.Client.change_scene_to(ClientMainScene)
