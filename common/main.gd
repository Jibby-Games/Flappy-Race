extends Node

const CLIENT_MAIN_SCENE = "res://client/menu/title/title_screen.tscn"
const SERVER_MAIN_SCENE = "res://server/world/world.tscn"


func _ready():
	if "--server" in OS.get_cmdline_args():
		Network.Server.change_scene(SERVER_MAIN_SCENE)
	else:
		Network.Client.change_scene(CLIENT_MAIN_SCENE)
