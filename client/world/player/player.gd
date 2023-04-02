extends CommonPlayer

const FLAP = 350

export(PackedScene) var ImpactParticles
export(PackedScene) var FlapParticles

var is_controlled
var player_state
var enable_death: bool = true
var player_name: String
var body_colour: Color
var flap_queue: Array


func _ready() -> void:
	$AnimationPlayer.set_assigned_animation("idle")
	# Stops all idle animations being in sync
	var start_time = rand_range(0, $AnimationPlayer.get_current_animation_length())
	$AnimationPlayer.seek(start_time)
	$AnimationPlayer.play()


func _physics_process(_delta: float) -> void:
	if is_controlled:
		update_player_state()
	elif not flap_queue.empty():
		for flap_time in flap_queue:
			# Ensure animation plays at correct time on client
			if flap_time <= Network.Client.client_clock:
				do_flap()
				flap_queue.erase(flap_time)
	# Make the sprite face the direction it's going
	$Sprites.rotation = velocity.angle()


func _input(event: InputEvent) -> void:
	if not is_controlled:
		return
	if event.is_action_pressed("flap"):
		Network.Client.send_player_flap()
		do_flap()
	if event.is_action_pressed("use_item") and not items.empty():
		var item: Item = items.pop_front()
		item.use(self)
		emit_signal("items_changed", self)


func update_player_state() -> void:
	player_state = {"T": Network.Client.client_clock, "P": get_global_position(), "V": velocity}
	Network.Client.send_player_state(player_state)


func do_flap() -> void:
	if enable_movement:
		velocity.y = -FLAP
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
		$Listener2D.make_current()


func disable_control() -> void:
	if is_controlled:
		is_controlled = false
		$Listener2D.clear_current()


func set_body_colour(value: int) -> void:
	body_colour = Globals.COLOUR_OPTIONS[value]
	$Sprites/Body.modulate = body_colour
	$Sprites/BodyOutline.modulate = body_colour
	$Sprites/Wing.modulate = body_colour
	$Sprites/EyesOutline.modulate = body_colour
	$Sprites/BeakOutline.modulate = body_colour
	$Trail.modulate = body_colour


func set_player_name(value: String) -> void:
	player_name = value
	$NameLabel.text = value
	$NameLabel.show()


func start() -> void:
	.start()
	$AnimationPlayer.play("RESET")


func death() -> void:
	if enable_death == false:
		return
	if coins > 0:
		$CoinLost.play()
	.death()


func on_death() -> void:
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


func add_coin(amount: int = 1) -> void:
	.add_coin(amount)
	$Coin.play()


func add_item(item: Item) -> void:
	.add_item(item)
	$Item.play()
