extends SceneHandler


export (PackedScene) var title_scene


var current_menu: PackedScene
var previous_menu: PackedScene


func _ready() -> void:
	_change_menu_to(title_scene)


func _change_menu_to(next_scene: PackedScene) -> void:
	.change_scene_to(next_scene)
	previous_menu = current_menu
	current_menu = next_scene
	assert(_active_scene.connect("change_menu_to", self, "change_menu_to") == OK)
	assert(_active_scene.connect("change_menu_to_previous", self, "change_menu_to_previous") == OK)


func change_menu_to(next_scene: PackedScene) -> void:
	$AnimationPlayer.play("fade_in")
	yield($AnimationPlayer, "animation_finished")
	_change_menu_to(next_scene)
	$AnimationPlayer.play_backwards("fade_in")
	yield($AnimationPlayer, "animation_finished")


func change_menu_to_previous() -> void:
	change_menu_to(previous_menu)
