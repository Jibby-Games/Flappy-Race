extends Area2D

export(int) var speed := 2000
export(int) var max_speed := 5000
export(int) var steer_force := 2000
export(float) var background_scale := 0.2
# How close to the target before going to the foreground
export(float) var foreground_proximity := 2000.0
# Slow down nearby to make flomb more noticeable
export(int) var foreground_max_speed := 800
export(float) var explosion_radius := 150.0
export(float) var explosion_time := 1.0


var world: Node2D
var velocity := transform.x * speed
var acceleration := Vector2.ZERO
var target_name: String
var target: Node2D = null
var is_homing := false
var in_background := false
var bodies_in_explosion_radius := []
var exploded := false


func _ready() -> void:
	if not target:
		if not target_name.empty():
			target = get_parent().get_node(target_name)
		else:
			push_error("Target must be set before adding to scene!")
	$ExplosionArea/CollisionShape2D.shape.radius = explosion_radius
	is_homing = true
	velocity = transform.x * speed
	move_to_background()
	world = get_parent()
	call_deferred("parent_to_target")


func seek() -> Vector2:
	var steer = Vector2.ZERO
	if target:
		var desired = (target.global_position - global_position).normalized() * speed
		steer = (desired - velocity)
	return steer


func _physics_process(delta: float) -> void:
	if is_homing and target and is_instance_valid(target):
		var distance_to_target := global_position.distance_to(target.global_position)
		if in_background and distance_to_target < foreground_proximity:
			move_to_foreground()
		acceleration += seek()
		velocity += acceleration * delta
		velocity = velocity.limit_length(max_speed)
		rotation = velocity.angle()
		position += velocity * delta
	$velocity.cast_to = velocity*0.1
	$acceleration.cast_to = acceleration*0.1


func move_to_background():
	in_foreground(false)
	in_background = true
	var tween = create_tween()
	tween.set_parallel(true)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_QUINT)
	tween.tween_property(self, "scale", Vector2(background_scale, background_scale), 2)
	self.monitoring = false


func move_to_foreground():
	max_speed = foreground_max_speed
	in_background = false
	self.monitoring = true
	var tween = create_tween()
	tween.set_parallel(true)
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_QUINT)
	tween.tween_property(self, "scale", Vector2.ONE, 2)
	tween.chain().tween_callback(self, "in_foreground", [true])


func in_foreground(in_foreground: bool) -> void:
	if in_foreground:
		self.z_index = 0
	else:
		# Appear behind all obstacles
		self.z_index = -5


func parent_to_target() -> void:
	call_deferred("set_global_position", global_position)
	world.remove_child(self)
	target.add_child(self)


func _on_Flomb_body_entered(body: Node) -> void:
	if exploded:
		# Only explode once
		return
	if is_instance_valid(body) and body.name == target.name:
		Logger.print(self, "Flomb exploded on player: %s", [body.name])
		call_deferred("explode")
		exploded = true


func explode() -> void:
	is_homing = false
	for body in bodies_in_explosion_radius:
		if body.has_method("death") and is_instance_valid(body):
			body.death()
	$ExplosionTimer.start(explosion_time)
	yield($ExplosionTimer, "timeout")
	queue_free()


func _on_ExplosionArea_body_entered(body: Node) -> void:
	bodies_in_explosion_radius.append(body)


func _on_ExplosionArea_body_exited(body: Node) -> void:
	bodies_in_explosion_radius.erase(body)
