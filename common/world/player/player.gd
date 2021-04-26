extends KinematicBody2D


class_name CommonPlayer


const UP = Vector2(0, -1)
const MAXFALLSPEED = 800
const GRAVITY = 17


signal death
signal score_point(player)


var motion = Vector2()
var high_score = 0
var score = 0
var is_dead = false
var has_gravity = true


func _physics_process(_delta) -> void:
	update_movement()


func update_movement() -> void:
	if is_dead:
		motion.x = 0
		motion.y = 0
		motion = move_and_slide(motion, UP)
		return

	if has_gravity:
		motion.y += GRAVITY
		if motion.y > MAXFALLSPEED:
			motion.y = MAXFALLSPEED

	motion.x = 0
	motion = move_and_slide(motion, UP)


func _on_Detect_area_entered(_area) -> void:
	# Detects entering the score zone. Signals to the world to update other nodes.
	score += 1
	if score > high_score:
		high_score = score
	emit_signal("score_point", self)


func death() -> void:
	is_dead = true
	emit_signal("death", self)


func _on_Detect_body_entered(_body) -> void:
	death()


func move_player(new_position : Vector2) -> void:
	set_position(new_position)
