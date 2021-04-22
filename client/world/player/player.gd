extends KinematicBody2D

var is_master = false
var is_dead = false

const UP = Vector2(0, -1)
const FLAP = 350
const MAXFALLSPEED = 800
const GRAVITY = 17

signal death
signal score_point(player)

var motion = Vector2()
var high_score = 0
var score = 0


func _ready():
	emit_signal("ready", self)


func _physics_process(_delta):
	if is_dead:
		motion.x = 0
		motion.y = 0
		motion = move_and_slide(motion, UP)
		return

	motion.y += GRAVITY
	if motion.y > MAXFALLSPEED:
		motion.y = MAXFALLSPEED

	if is_master and Input.is_action_just_pressed("ui_accept"):
		do_flap()
		Network.Client.send_flap()

	motion.x = 0
	motion = move_and_slide(motion, UP)


func do_flap() -> void:
	motion.y = -FLAP
	play_flap_sound()


remotesync func play_flap_sound():
	var choice = int(rand_range(0, 4))
	match choice:
		0:
			$Flap1.play()
		1:
			$Flap2.play()
		2:
			$Flap3.play()
		3:
			$Flap4.play()
		_:
			print("Invalid choice!")


remote func update_position(pos):
	position = pos


func _on_Detect_area_entered(_area):
	# Detects entering the score zone. Signals to the world to update other nodes.
	score += 1
	if score > high_score:
		high_score = score
	emit_signal("score_point", self)

func death():
	is_dead = true
	$DeathSound.play()


func _on_Detect_body_entered(_body):
	death()


func _on_DeathSound_finished():
	print("Deathsound finished")
	emit_signal("death", self)
