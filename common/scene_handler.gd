extends Node

class_name SceneHandler

var _active_scene: Node


func change_scene(scene_path: String) -> void:
	var scene = load(scene_path)
	change_scene_to(scene)


func change_scene_to(scene: PackedScene) -> void:
	assert(scene != null, "SceneHandler tried to use a scene that doesn't exist!")
	Logger.print(self, "Changing scene to %s" % [scene.get_path()])
	unload_scene()
	var new_scene: Node = scene.instance()
	add_child(new_scene)
	_active_scene = new_scene


func unload_scene() -> void:
	if _active_scene != null:
		remove_child(_active_scene)
		_active_scene.queue_free()
