extends SceneHandler

var scroll_x = 0
var scroll_speed = 200


func _ready() -> void:
	$MusicPlayer.play_track_name("Drozerix - Digital Rendezvous")
	$ParallaxClouds/ParallaxBackground.offset = Vector2.ZERO
	$ParallaxClouds/ParallaxForeground.offset = Vector2.ZERO
	$ParallaxClouds/ParallaxForeground.layer = -1


func _process(delta: float) -> void:
	# This makes the parallax background move without a character
	scroll_x -= delta * scroll_speed
	$ParallaxClouds/ParallaxBackground.scroll_offset.x = scroll_x
	$ParallaxClouds/ParallaxForeground.scroll_offset.x = scroll_x


func change_menu(next_scene: String) -> void:
	.change_scene(next_scene)
	var result: int
	result = _active_scene.connect("change_menu", self, "change_menu_with_fade")
	assert(result == OK)


func change_menu_with_fade(next_scene_path: String) -> void:
	change_menu(next_scene_path)

	# This allows the next menu's network logic to work during the animation
	_active_scene.hide()
	$AnimationPlayer.play("fade_in")
	yield($AnimationPlayer, "animation_finished")
	_active_scene.show()
	$AnimationPlayer.play_backwards("fade_in")
	yield($AnimationPlayer, "animation_finished")
