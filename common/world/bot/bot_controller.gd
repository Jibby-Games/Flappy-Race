extends Node2D

var bottom_edge: int = ProjectSettings.get_setting("display/window/size/height") / 2
var player: CommonPlayer
var target_pos := Vector2(100000, 0)
var target_marker
var below_target_threshold := 16
var ahead_of_target_threshold := 128
var flap_detector_bodies := []
var forward_detector_bodies := []
var flap_lookahead := 96
var forward_lookahead := 64
var verbose_bot := false
var flap_timer := 0.0
var in_flap_cooldown := false
var flap_cooldown_seconds := 0.1

onready var nav_agent: NavigationAgent2D = $NavigationAgent2D

func _ready():
	nav_agent.set_target_location(target_pos)
	player = get_parent()
	var result := player.connect("death", self, "_on_player_death")
	assert(result == OK)


func _physics_process(delta: float) -> void:
	if not player.enable_movement:
		# Player can't move yet so take no action
		return
	$FlapDetector.position = Vector2(player.velocity.x, -player.FLAP).normalized() * flap_lookahead
	$ForwardDetector.position = player.velocity.normalized() * forward_lookahead
	# Add a cooldown so flaps don't get spammed
	if in_flap_cooldown:
		flap_timer += delta
		if flap_timer >= flap_cooldown_seconds:
			in_flap_cooldown = false
			flap_timer = 0.0
	elif should_flap():
		in_flap_cooldown = true
		player.do_flap()


func should_flap() -> bool:
	if is_near_bottom():
		if verbose_bot: print("flap due to near bottom")
		return true
	if $DownRaycast.is_colliding():
		if verbose_bot: print("flap due to down ray")
		return true
	if $UpRaycast.is_colliding():
		if verbose_bot: print("NO flap due to up ray")
		return false
	if not flap_detector_bodies.empty():
		if verbose_bot: print("NO flap due to flap detector")
		return false
	if not forward_detector_bodies.empty():
		if verbose_bot: print("flap due to forward detector")
		return true
	var nav_pos := nav_agent.get_next_location()
	draw_debug_point(nav_pos, Color.red)
	if player.global_position.x + ahead_of_target_threshold >= nav_pos.x:
		nav_agent.set_target_location(target_pos)
	if nav_pos.y + below_target_threshold < player.global_position.y:
		if verbose_bot: print("flap due to below nav target")
		return true
	return false

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
