extends KinematicBody2D


class_name CommonPlayer


const MAXFALLSPEED = 800
const GRAVITY = 17
const BASE_SPEED = 500
const DEATH_COOLDOWN_TIME = 1
const COIN_BOOST := 20
const COIN_LIMIT := 10


signal death(player)
signal score_changed(player)
signal coins_changed(player)


var in_death_cooldown: bool = false
var score := 0
var coins := 0

# Movement vars
var motion: Vector2 = Vector2()
var enable_movement: bool = true
var has_gravity: bool = true


func _physics_process(_delta: float) -> void:
	update_movement()
	check_position()


func update_movement() -> void:
	if not enable_movement:
		motion.x = 0
		motion.y = 0
		motion = move_and_slide(motion, Vector2.UP)
		return

	if has_gravity:
		motion.y += GRAVITY
		if motion.y > MAXFALLSPEED:
			motion.y = MAXFALLSPEED

	motion.x = BASE_SPEED + (coins * COIN_BOOST)
	motion = move_and_slide(motion, Vector2.UP)


func check_position() -> void:
	var upper_bound = (ProjectSettings.get_setting("display/window/size/height") / 2)

	# Give the player a chance to recover from death
	var threshold = 200
	if abs(self.position.y) > (upper_bound + threshold):
		death()


func _on_Detect_area_entered(_area: Area2D) -> void:
	Logger.print(self, "Player %s entered area %s" % [self.name, _area.name])


func _on_Detect_body_entered(_body: Node) -> void:
	Logger.print(self, "Player %s entered body %s" % [self.name, _body.name])
	death()


func death() -> void:
	if in_death_cooldown:
		return
	in_death_cooldown = true
	emit_signal("death", self)
	$DeathCooldownTimer.start(DEATH_COOLDOWN_TIME)
	on_death()


func on_death() -> void:
	# Used on the client
	pass


func despawn() -> void:
	queue_free()


func _on_DeathCooldownTimer_timeout() -> void:
	in_death_cooldown = false


func set_enable_movement(_new_value: bool) -> void:
	enable_movement = _new_value


func move_player(new_position: Vector2) -> void:
	set_position(new_position)


func add_score() -> void:
	score += 1
	emit_signal("score_changed", self)


func add_coin() -> void:
	if coins < COIN_LIMIT:
		coins += 1
		emit_signal("coins_changed", self)
		Logger.print(self, "Player %s got a coin! Coins = %d" % [self.name, coins])
