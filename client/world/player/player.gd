extends CommonPlayer


const FLAP = 350


export(PackedScene) var PlayerController
# Colour palette by PineappleOnPizza: https://lospec.com/palette-list/bubblegum-16
export(PoolColorArray) var colour_options: PoolColorArray = [
	"#d62411",
	"#7f0622",
	"#ff8426",
	"#ffd100",
	"#ff80a4",
	"#ff2674",
	"#94216a",
	"#430067",
	"#234975",
	"#68aed4",
	"#bfff3c",
	"#10d275",
	"#007899",
	"#002859",
	"#fafdff",
	"#16171a",
]
export(PackedScene) var ImpactParticles

var is_controlled
var player_state
var enable_death_animation: bool = true
var player_name: String
var body_colour: Color


func _ready() -> void:
	$Sprites/AnimatedOutline.playing = true


func _physics_process(_delta: float) -> void:
	if is_controlled:
		update_player_state()


func update_player_state() -> void:
	player_state = {"T": Network.Client.client_clock, "P": get_global_position()}
	Network.Client.send_player_state(player_state)


func do_flap() -> void:
	if enable_movement:
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
	body_colour = colour_options[value]
	$Sprites/Body.modulate = body_colour


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
	$AnimationPlayer.play("DeathCooldown")
	spawn_particles()


func despawn() -> void:
	$DeathSound.play()
	$Sprites.hide()
	$DespawnSprite.show()
	$DespawnSprite.playing = true
	spawn_particles()
	# Delay freeing so the sound can finish playing
	yield(get_tree().create_timer(1), "timeout")
	queue_free()


func spawn_particles() -> void:
	var particles: Particles2D = ImpactParticles.instance()
	particles.set_modulate(body_colour)
	particles.set_global_position(get_global_position())
	particles.set_emitting(true)
	$"..".add_child(particles)


func add_coin() -> void:
	.add_coin()
	$Coin.play()
