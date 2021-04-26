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
var player_state
var is_master = false
var is_dead = false
var has_gravity = true

func _ready() -> void:
	emit_signal("ready", self)


func _physics_process(_delta) -> void:
	update_movement()
	update_player_state()


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

	if is_master and Input.is_action_just_pressed("ui_accept"):
		do_flap()

	motion.x = 0
	motion = move_and_slide(motion, UP)


func do_flap() -> void:
	motion.y = -FLAP
	play_flap_sound()


func update_player_state() -> void:
	# T is only used to determine which player_state is the latest on the server
	# So it doesn't need to use the client_clock
	player_state = {"T": OS.get_system_time_msecs(), "P": get_global_position()}
	Network.Client.send_player_state(player_state)


remotesync func play_flap_sound() -> void:
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


func _on_Detect_area_entered(_area) -> void:
	# Detects entering the score zone. Signals to the world to update other nodes.
	score += 1
	if score > high_score:
		high_score = score
	emit_signal("score_point", self)


func death() -> void:
	is_dead = true
	$DeathSound.play()


func _on_Detect_body_entered(_body) -> void:
	death()


func _on_DeathSound_finished() -> void:
	print("Deathsound finished")
	emit_signal("death", self)


func move_player(new_position : Vector2) -> void:
	set_position(new_position)
