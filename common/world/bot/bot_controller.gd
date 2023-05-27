extends Node2D

class_name BotController

var bottom_edge: int = ProjectSettings.get_setting("display/window/size/height") / 2
var player: CommonPlayer
var target_pos := Vector2(100000, 0)
var target_marker: Line2D
var last_nav_pos := Vector2.ZERO
var below_target_threshold := 16
var ahead_of_target_threshold := 128
var flap_detector_bodies := []
var forward_detector_bodies := []
var flap_lookahead := 96
var forward_lookahead := 64
var verbose_bot := false
var difficulty := 1.0 setget set_difficulty

# Flap cooldown
var flap_timer := 0.0
var in_flap_cooldown := false
var flap_cooldown_seconds := 0.1

# Mistake cooldown
var enable_mistakes := false
var mistake_timer := 0.0
var in_mistake_cooldown := false
var mistake_cooldown_seconds := 1.0
var mistake_chance := 0.0

onready var nav_agent: NavigationAgent2D = $NavigationAgent2D

func _ready():
	nav_agent.set_target_location(target_pos)
	player = get_parent()
	var result := player.connect("death", self, "_on_player_death")
	assert(result == OK)


func _physics_process(delta: float) -> void:
	$FlapDetector.position = Vector2(player.velocity.x, -player.FLAP).normalized() * flap_lookahead
	$ForwardDetector.position = player.velocity.normalized() * forward_lookahead
	# Add a cooldown so flaps and mistakes don't get spammed
	if in_mistake_cooldown:
		mistake_timer += delta
		if mistake_timer >= mistake_cooldown_seconds:
			in_mistake_cooldown = false
			mistake_timer = 0.0
	if in_flap_cooldown:
		flap_timer += delta
		if flap_timer >= flap_cooldown_seconds:
			in_flap_cooldown = false
			flap_timer = 0.0
	elif player.enable_movement and should_flap():
		in_flap_cooldown = true
		player.do_flap()
		if Network.Server:
			Network.Server.send_player_flap(int(player.name), OS.get_system_time_msecs())
	if Network.Server:
		update_player_state()


func update_player_state() -> void:
	var player_state := {"T": OS.get_system_time_msecs(), "P": player.get_global_position(), "V": player.velocity}
	Network.Server.add_player_state(int(player.name), player_state)


func should_flap() -> bool:
	if enable_mistakes and not in_mistake_cooldown and randf() < mistake_chance:
		if verbose_bot: print("made a mistake!")
		in_mistake_cooldown = true
		# Randomly flap or don't flap
		return bool(randi() % 2)
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

	# Calculate the next nav pos
	var nav_pos := nav_agent.get_next_location()
	# Just carry on straight if nav pos is out of bounds
	if nav_pos.y > bottom_edge or nav_pos.y < -bottom_edge:
		nav_pos.y = last_nav_pos.y
	draw_debug_point(nav_pos, Color.red)
	last_nav_pos = nav_pos
	if verbose_bot: print_debug("%s nav point: %s" % [player.name, nav_pos])

	if player.global_position.x + ahead_of_target_threshold >= nav_pos.x:
		# Recalculate next target location if near the next nav pos
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


func set_difficulty(value: float) -> void:
	if value < 0.0 or value > 1.0:
		push_error("Difficulty must be between 0.0 and 1.0! Value: %f" % value)
		return
	difficulty = value
	if difficulty == 1.0:
		# The hardest bots shouldn't make any mistakes!
		enable_mistakes = false
		Logger.print(self, "Difficulty set to %f, mistakes disabled", [difficulty])
		return
	enable_mistakes = true
	mistake_chance = 1.0 - difficulty
	mistake_cooldown_seconds = (10 * difficulty)
	Logger.print(self, "Difficulty set to %f, mistakes mistake_chance = %f mistake_cooldown = %f", [difficulty, mistake_chance, mistake_cooldown_seconds])


func _on_player_death(_player: CommonPlayer) -> void:
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
