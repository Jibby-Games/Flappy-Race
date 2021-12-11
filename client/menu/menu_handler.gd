extends SceneHandler


export (PackedScene) var title_scene


var current_menu: PackedScene
var previous_menu: PackedScene
var scroll_x = 0
var scroll_speed = 200

func _ready() -> void:
	_change_menu_to(title_scene)
	$MusicPlayer.play_track_name("Drozerix - Digital Rendezvous")


func _process(delta: float) -> void:
	# This makes the parallax background move without a character
	scroll_x -= delta * scroll_speed
	$ParallaxBackground.scroll_offset.x = scroll_x


func _change_menu_to(next_scene: PackedScene) -> void:
	.change_scene_to(next_scene)
	previous_menu = current_menu
	current_menu = next_scene
	var result: int
	result = _active_scene.connect("change_menu_to", self, "change_menu_to")
	assert(result == OK)
	result = _active_scene.connect("change_menu_to_previous", self, "change_menu_to_previous")
	assert(result == OK)


func change_menu_to(next_scene: PackedScene) -> void:
	_change_menu_to(next_scene)
	# This allows the next menu's network logic to work during the animation
	_active_scene.hide()
	$AnimationPlayer.play("fade_in")
	yield($AnimationPlayer, "animation_finished")
	_active_scene.show()
	$AnimationPlayer.play_backwards("fade_in")
	yield($AnimationPlayer, "animation_finished")


func change_menu_to_previous() -> void:
	change_menu_to(previous_menu)
