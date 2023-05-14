extends Node2D

var bottom_edge: int = ProjectSettings.get_setting("display/window/size/height") / 2
var player: CommonPlayer

onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
var target_pos := Vector2(100000, 0)
var target_marker
var flap_detector_bodies := []
var forward_detector_bodies := []
var flap_delta_lookahead := 12
var forward_delta_lookahead := 6


func _ready():
	nav_agent.set_target_location(target_pos)
	player = owner
	var result := player.connect("death", self, "_on_player_death")
	assert(result == OK)


func _physics_process(delta: float) -> void:
	$FlapDetector.position = Vector2(player.velocity.x, -player.FLAP) * delta * flap_delta_lookahead
	$ForwardDetector.position = player.velocity * delta * forward_delta_lookahead
	if should_flap():
		player.do_flap()


func should_flap() -> bool:
	if is_near_bottom():
		return true
	if $DownRaycast.is_colliding():
		return true
	if $UpRaycast.is_colliding():
		return false
	if not flap_detector_bodies.empty():
		return false
	if not forward_detector_bodies.empty():
		return true
	var nav_pos := nav_agent.get_next_location()
	if player.global_position.x >= nav_pos.x:
		nav_agent.set_target_location(target_pos)
		nav_pos = nav_agent.get_next_location()
	draw_debug_point(nav_pos, Color.red)
	return nav_pos.y + 32 < player.global_position.y

func draw_debug_point(pos: Vector2, col: Color = Color.white) -> void:
	if target_marker:
		target_marker.queue_free()
	var inst := Line2D.new()
	inst.points = [Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]
	inst.width = 10
	inst.default_color = col
	inst.position = pos
	target_marker = inst
	player.get_parent().add_child(inst)


func is_near_bottom() -> bool:
	return player.position.y >= bottom_edge


func _on_player_death(_player) -> void:
	#TODO randomize route just in case we get stuck on one
	nav_agent.set_target_location(target_pos)


func _on_FlapDetector_body_entered(body:Node) -> void:
	flap_detector_bodies.append(body)


func _on_FlapDetector_body_exited(body:Node) -> void:
	flap_detector_bodies.erase(body)


func _on_ForwardDetector_body_entered(body:Node) -> void:
	forward_detector_bodies.append(body)


func _on_ForwardDetector_body_exited(body:Node) -> void:
	forward_detector_bodies.erase(body)
