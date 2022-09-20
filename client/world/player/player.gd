extends CommonPlayer


const FLAP = 350


export(PackedScene) var PlayerController
export(PackedScene) var ImpactParticles
export(PackedScene) var FlapParticles


var is_controlled
var player_state
var enable_death_animation: bool = true
var player_name: String
var body_colour: Color


func _ready() -> void:
	$AnimationPlayer.set_assigned_animation("idle")
	# Stops all idle animations being in sync
	var start_time = rand_range(0, $AnimationPlayer.get_current_animation_length())
	$AnimationPlayer.seek(start_time)
	$AnimationPlayer.play()


func _physics_process(_delta: float) -> void:
	# Make the sprite face the direction it's going
	$Sprites.rotation = motion.angle()
	if is_controlled:
		update_player_state()


func update_player_state() -> void:
	player_state = {"T": Network.Client.client_clock, "P": get_global_position()}
	Network.Client.send_player_state(player_state)


func do_flap() -> void:
	if enable_movement:
		motion.y = -FLAP
		play_flap_sound()
		spawn_flap_particles()
		$AnimationPlayer.play("flap")


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
			Logger.print(self, "Invalid choice!")


func enable_control() -> void:
	if not is_controlled:
		is_controlled = true
		var controller = PlayerController.instance()
		controller.connect("flap", self, "do_flap")
		add_child(controller)


func disable_control() -> void:
	if is_controlled:
		is_controlled = false
		var controller = $PlayerController
		if controller:
			controller.queue_free()


func set_body_colour(value: int) -> void:
	body_colour = Globals.COLOUR_OPTIONS[value]
	$Sprites/Body.modulate = body_colour
	$Trail.modulate = body_colour


func set_player_name(value: String) -> void:
	player_name = value
	$NameLabel.text = value
	$NameLabel.show()


func death() -> void:
	if coins > 0:
		$CoinLost.play()
	.death()


func on_death() -> void:
	if enable_death_animation == false:
		return
	$DeathSound.play()
	$AnimationPlayer.play("death_cooldown")
	spawn_impact_particles()


func despawn() -> void:
	$DeathSound.play()
	$Sprites.hide()
	$Trail.hide()
	$DespawnSprite.show()
	$DespawnSprite.playing = true
	spawn_impact_particles()
	# Delay freeing so the sound can finish playing
	yield(get_tree().create_timer(1), "timeout")
	queue_free()


func spawn_impact_particles() -> void:
	var particles: Particles2D = ImpactParticles.instance()
	particles.set_modulate(body_colour)
	particles.set_emitting(true)
	add_child(particles)


func spawn_flap_particles() -> void:
	var particles: Particles2D = FlapParticles.instance()
	particles.set_emitting(true)
	add_child(particles)


func add_coin() -> void:
	.add_coin()
	$Coin.play()
