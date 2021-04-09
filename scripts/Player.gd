extends KinematicBody2D

const UP = Vector2(0, -1)
const FLAP = 350
const MAXFALLSPEED = 800
const GRAVITY = 17

signal death
signal score_point(player)

var motion = Vector2()
var high_score = 0
var score = 0

func _physics_process(_delta):
	motion.y += GRAVITY
	if motion.y > MAXFALLSPEED:
		motion.y = MAXFALLSPEED

	if Input.is_action_just_pressed("ui_accept"):
		motion.y = -FLAP

	motion.x = 0
	motion = move_and_slide(motion, UP)
	

func _on_Detect_area_entered(_area):
	emit_signal("score_point", self)


func death():
	emit_signal("death", self)


func _on_Detect_body_entered(_body):
	death()
