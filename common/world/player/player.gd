extends KinematicBody2D

class_name CommonPlayer

const MAXFALLSPEED = 800
const GRAVITY = 17
const BASE_SPEED = 500
const DEATH_COOLDOWN_TIME = 1
const COIN_BOOST := 20
const COINS_LOST_ON_DEATH := 3
const MAX_ITEMS := 1
const ITEM_USE_DELAY := 1.8
const WALL_COLLISION_LAYER := 1

signal death(player)
signal score_changed(player)
signal coins_changed(player)
signal got_item(player, item)
signal finish(player)

var in_death_cooldown: bool = false
var score := 0
var coins := 0
var items := []
var checkpoint_position := Vector2()

# Movement vars
var velocity: Vector2 = Vector2()
var enable_movement: bool = true
var has_gravity: bool = true


func _physics_process(_delta: float) -> void:
	update_movement()
	if is_position_out_of_bounds(self.position):
		death()


func update_movement() -> void:
	if not enable_movement:
		velocity.x = 0
		velocity.y = 0
		velocity = move_and_slide(velocity, Vector2.UP)
		return

	if has_gravity:
		velocity.y += GRAVITY
		if velocity.y > MAXFALLSPEED:
			velocity.y = MAXFALLSPEED

	velocity.x = BASE_SPEED + (coins * COIN_BOOST)
	velocity = move_and_slide(velocity, Vector2.UP)


func is_position_out_of_bounds(pos: Vector2) -> bool:
	var upper_bound = ProjectSettings.get_setting("display/window/size/height") / 2

	# Give the player a chance to recover from death
	var threshold = 200
	return abs(pos.y) > (upper_bound + threshold)


func _on_Detect_area_entered(_area: Area2D) -> void:
	Logger.print(self, "Player %s entered area %s" % [self.name, _area.name])


func _on_Detect_body_entered(_body: Node) -> void:
	Logger.print(self, "Player %s entered body %s" % [self.name, _body.name])
	death()


func start() -> void:
	enable_movement = true


func death() -> void:
	if in_death_cooldown:
		return
	in_death_cooldown = true
	enable_movement = false
	emit_signal("death", self)
	$DeathCooldownTimer.start(DEATH_COOLDOWN_TIME)
	if coins > 0:
		coins -= COINS_LOST_ON_DEATH
		if coins < 0:
			coins = 0
		Logger.print(self, "Player %s lost some coins! Coins = %d" % [self.name, coins])
		emit_signal("coins_changed", self)
	on_death()


func on_death() -> void:
	knockback()


func despawn() -> void:
	queue_free()


func _on_DeathCooldownTimer_timeout() -> void:
	in_death_cooldown = false
	enable_movement = true


func set_enable_movement(_new_value: bool) -> void:
	enable_movement = _new_value


func move_player(new_position: Vector2, new_velocity: Vector2) -> void:
	set_global_position(new_position)
	velocity = new_velocity


func add_score() -> void:
	score += 1
	emit_signal("score_changed", self)


func add_coin(amount: int = 1) -> void:
	coins += amount
	emit_signal("coins_changed", self)
	Logger.print(self, "Player %s got a coin! Coins = %d" % [self.name, coins])


func add_item(item: Item) -> void:
	if items.size() >= MAX_ITEMS:
		# Cannot add any more items
		return
	items.append(item)
	Logger.print(self, "Player %s got item %s", [self.name, item.name])
	emit_signal("got_item", self, item)
	yield(get_tree().create_timer(ITEM_USE_DELAY), "timeout")
	use_item()


# Uses the next item in the player's inventory
func use_item() -> void:
	var item = items.pop_front()
	item.use(self)
	Logger.print(self, "Player %s used item %s", [self.name, item.name])


func finish() -> void:
	add_score()
	emit_signal("finish", self)


func knockback() -> void:
	Logger.print(self, "Knocking player %s back to %s" % [name, checkpoint_position])
	set_global_position(checkpoint_position)


func start_invisibility(duration: int) -> void:
	$InvisibilityTimer.start(duration)
	set_invisible(true)


func _on_InvisibilityTimer_timeout() -> void:
	set_invisible(false)


func set_invisible(value: bool) -> void:
	self.set_collision_mask_bit(WALL_COLLISION_LAYER, not value)
	$Detect.set_collision_mask_bit(WALL_COLLISION_LAYER, not value)


func start_shrinkage(duration: int) -> void:
	$ShrinkageTimer.start(duration)
	set_shrunk(true)


func _on_ShrinkageTimer_timeout() -> void:
	set_shrunk(false)


func set_shrunk(value: bool) -> void:
	if value:
		self.scale = Vector2(0.5, 0.5)
	else:
		self.scale = Vector2.ONE
