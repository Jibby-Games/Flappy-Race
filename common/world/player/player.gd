extends KinematicBody2D


class_name CommonPlayer


const MAXFALLSPEED = 800
const GRAVITY = 17
const BASE_SPEED = 500


signal death(player)
signal score_point(player)


var motion: Vector2 = Vector2()
var score: int = 0
var enable_movement: bool = true
var has_gravity: bool = true


func _physics_process(_delta: float) -> void:
	update_movement()
	check_position()


func update_movement() -> void:
	if not enable_movement:
		motion.x = 0
		motion.y = 0
		motion = move_and_slide(motion, Vector2.UP)
		return

	if has_gravity:
		motion.y += GRAVITY
		if motion.y > MAXFALLSPEED:
			motion.y = MAXFALLSPEED

	motion.x = BASE_SPEED
	motion = move_and_slide(motion, Vector2.UP)


func check_position() -> void:
	var upper_bound = (ProjectSettings.get_setting("display/window/size/height") / 2) + 200
	var lower_bound = -upper_bound
	if self.position.y > upper_bound or self.position.y < lower_bound:
		emit_signal("death", self)


func _on_Detect_area_entered(_area: Area2D) -> void:
	Logger.print(self, "Player entered area %s" % [_area.name])
	# Detects entering the score zone. Signals to the world to update other nodes.
	score += 1
	emit_signal("score_point", self)


func _on_Detect_body_entered(_body: Node) -> void:
	Logger.print(self, "Player entered body %s" % [_body.name])
	emit_signal("death", self)


func set_enable_movement(_new_value: bool) -> void:
	enable_movement = _new_value


func move_player(new_position: Vector2) -> void:
	set_position(new_position)
