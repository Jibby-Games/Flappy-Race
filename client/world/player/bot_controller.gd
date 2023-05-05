extends Node2D

var bottom_edge: int = ProjectSettings.get_setting("display/window/size/height") / 2
var player: CommonPlayer

onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
var target_pos := Vector2(100000, 0)
var target_marker


func _ready():
	nav_agent.set_target_location(target_pos)
	player = owner
	var result := player.connect("death", self, "_on_player_death")
	assert(result == OK)


func _physics_process(_delta: float) -> void:
	$ForwardRay.rotation = player.velocity.angle()
	if should_flap():
		player.do_flap()


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


func should_flap() -> bool:
	if is_near_bottom():
		return true
	if $BottomRay.is_colliding():
		return true
	if $TopRay.is_colliding():
		return false
	if $ForwardRay.is_colliding():
		return true
	var nav_pos := nav_agent.get_next_location()
	draw_debug_point(nav_pos)
	if player.global_position.x >= nav_pos.x:
		nav_agent.set_target_location(target_pos)
		nav_pos = nav_agent.get_next_location()
	if nav_pos.y < -1000:
		nav_pos.y = 0
	return nav_pos.y + 20 < player.global_position.y


func is_near_bottom() -> bool:
	return player.position.y >= bottom_edge


func _on_player_death(_player) -> void:
	nav_agent.set_target_location(target_pos)
