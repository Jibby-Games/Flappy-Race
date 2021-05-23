extends Node


class_name SceneHandler


var _active_scene: Node


func change_scene(scene_path: String) -> void:
	var scene = load(scene_path)
	change_scene_to(scene)


func change_scene_to(scene: PackedScene) -> void:
	if _active_scene != null:
		remove_child(_active_scene)
		_active_scene.queue_free()
	var new_scene: Node = scene.instance()
	add_child(new_scene)
	_active_scene = new_scene
