extends KinematicBody2D


class_name CommonPlayer


const MAXFALLSPEED = 800
const GRAVITY = 17
const BASE_SPEED = 500


signal death
signal score_point(player)


var motion = Vector2()
var score = 0
var is_dead = false
var has_gravity = true


func _physics_process(_delta) -> void:
	update_movement()


func update_movement() -> void:
	if is_dead:
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


func _on_Detect_area_entered(_area) -> void:
	print("[%s] Player entered area %s" % [get_path().get_name(1), _area.name])
	# Detects entering the score zone. Signals to the world to update other nodes.
	score += 1
	emit_signal("score_point", self)


func _on_Detect_body_entered(_body) -> void:
	death()


func death() -> void:
	is_dead = true
	emit_signal("death", self)


func move_player(new_position : Vector2) -> void:
	set_position(new_position)
