extends CommonPlayer


const FLAP = 350


export(PackedScene) var PlayerController


var is_controlled
var player_state


func _physics_process(_delta) -> void:
	if is_controlled:
		update_player_state()


func update_player_state() -> void:
	player_state = {"T": Network.Client.client_clock, "P": get_global_position()}
	Network.Client.send_player_state(player_state)


func do_flap() -> void:
	if not is_dead:
		motion.y = -FLAP
		play_flap_sound()


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


func enable_control():
	if not is_controlled:
		is_controlled = true
		var controller = PlayerController.instance()
		controller.connect("flap", self, "do_flap")
		add_child(controller)


func disable_control():
	if is_controlled:
		is_controlled = false
		var controller = $PlayerController
		if controller:
			controller.queue_free()
