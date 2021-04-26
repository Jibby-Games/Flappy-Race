extends CommonPlayer


const FLAP = 350


var player_state
var is_master = false


func _physics_process(_delta) -> void:
	update_player_state()


func update_movement() -> void:
	if is_master and not is_dead and Input.is_action_just_pressed("ui_accept"):
		do_flap()
	.update_movement()


func do_flap() -> void:
	motion.y = -FLAP
	play_flap_sound()


func update_player_state() -> void:
	# T is only used to determine which player_state is the latest on the server
	# So it doesn't need to use the client_clock
	player_state = {"T": OS.get_system_time_msecs(), "P": get_global_position()}
	Network.Client.send_player_state(player_state)


func play_flap_sound() -> void:
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
