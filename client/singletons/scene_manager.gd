extends Node

onready var _scenes = {
	Enums.Scene.WORLD: preload("res://client/world/world.tscn"),
	Enums.Scene.TITLE: preload("res://client/menu/title/title_screen.tscn"),
	Enums.Scene.CLIENT: preload("res://client/client_network.tscn"),
	Enums.Scene.CLIENT_SERVER: preload("res://client/client_server_network.tscn"),
	Enums.Scene.SERVER: preload("res://server/server_network.tscn"),
}

func change_to(scene : int):
	assert(scene in Enums.Scene.values(), "Argument must be a valid 'Enums.Scene' enum value!")
	assert(get_tree().change_scene_to(_scenes[scene]) == OK, "Error when changing scene to " + str(scene))
