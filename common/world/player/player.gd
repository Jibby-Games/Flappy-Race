class_name CommonPlayer extends KinematicBody2D

const FLAP = 350
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
var is_bot := false
var finish_line_position := Vector2()
var is_finished := false

# Movement vars
var velocity: Vector2 = Vector2()
var acceleration: Vector2 = Vector2()
export var enable_movement: bool = true
var has_gravity: bool = true


func _physics_process(_delta: float) -> void:
	update_movement()
	if is_position_out_of_bounds(self.position):
		death("Out of bounds")
	if self.position.x >= finish_line_position.x:
		# Ensures players always trigger the finish
		finish()


func update_movement() -> void:
	velocity = calculate_next_velocity(velocity)
	velocity = move_and_slide(velocity, Vector2.UP)


func calculate_next_velocity(current_velocity: Vector2) -> Vector2:
	if not enable_movement:
		return Vector2.ZERO
	var next_velocity := current_velocity
	if has_gravity:
		next_velocity.y += GRAVITY
		if next_velocity.y > MAXFALLSPEED:
			next_velocity.y = MAXFALLSPEED

	next_velocity.x = BASE_SPEED + (coins * COIN_BOOST)
	next_velocity += acceleration
	return next_velocity


func is_position_out_of_bounds(pos: Vector2) -> bool:
	var upper_bound = ProjectSettings.get_setting("display/window/size/height") / 2

	# Give the player a chance to recover from death
	var threshold = 200
	return abs(pos.y) > (upper_bound + threshold)


func _on_Detect_area_entered(_area: Area2D) -> void:
	Logger.print(self, "Player %s entered area %s" % [self.name, _area.name])


func _on_Detect_body_entered(_body: Node) -> void:
	Logger.print(self, "Player %s entered body %s" % [self.name, _body.name])
	death("Collided with wall")


func start() -> void:
	enable_movement = true
	is_finished = false


func do_flap() -> void:
	if enable_movement:
		velocity.y = -FLAP


func set_enable_wall_collisions(value: bool) -> void:
	set_collision_mask_bit(WALL_COLLISION_LAYER, value)
	$Detect.set_collision_mask_bit(WALL_COLLISION_LAYER, value)


func death(reason: String = "") -> void:
	if in_death_cooldown:
		return
	in_death_cooldown = true
	enable_movement = false
	emit_signal("death", self)
	$DeathCooldownTimer.start(DEATH_COOLDOWN_TIME)
	Logger.print(self, "Player %s died at %s! Reason: %s", [self.name, self.position, reason])
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
	on_respawn()


func on_respawn() -> void:
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
	$ItemDelayTimer.start(ITEM_USE_DELAY)
	yield($ItemDelayTimer, "timeout")
	use_item()


# Uses the next item in the player's inventory
func use_item() -> void:
	var item = items.pop_front()
	item.use(self)
	Logger.print(self, "Player %s used item %s", [self.name, item.name])


func finish() -> void:
	if is_finished:
		# Only call finish once per player
		return
	is_finished = true
	add_score()
	emit_signal("finish", self)


func knockback() -> void:
	Logger.print(self, "Knocking player %s back to %s" % [name, checkpoint_position])
	set_global_position(checkpoint_position)


func get_progress() -> float:
	# Account for body radius
	return (self.position.x + 16) / finish_line_position.x
