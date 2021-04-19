extends Node

onready var _scenes = {
	Enums.Scene.WORLD: preload("res://client/world/world.tscn"),
	Enums.Scene.TITLE: preload("res://client/menu/title_screen.tscn"),
}

func change_to(scene : int):
	assert(scene in Enums.Scene.values(), "Argument must be a valid 'Scene' enum value!")
	assert(get_tree().change_scene_to(_scenes[scene]) == OK, "Error when changing scene to " + str(scene))
