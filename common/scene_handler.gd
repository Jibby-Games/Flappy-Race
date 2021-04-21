extends Node


class_name SceneHandler


var _active_scene: Node


func change_scene(scene_path: String) -> void:
	var scene = load(scene_path)
	change_scene_to(scene)


func change_scene_to(scene: PackedScene) -> void:
	print("Changing scene to %s" % scene.get_path())
	var new_scene: Node = scene.instance()
	if _active_scene != null:
		_active_scene.queue_free()
	add_child(new_scene)
	_active_scene = new_scene
