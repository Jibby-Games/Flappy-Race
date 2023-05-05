extends Node

# export var num_rays := 6

# var rays := []
# var interest := []
# var danger := []

var bottom_edge: int = ProjectSettings.get_setting("display/window/size/height") / 2

# func _ready():
# 	# interest.resize(num_rays)
# 	# danger.resize(num_rays)
# 	rays.resize(num_rays)
# 	for i in num_rays:
# 		var ray := RayCast2D.new()
# 		var angle = i * PI / num_rays
# 		ray.rotate(angle)
# 		$Player.add_child(ray)


func _physics_process(_delta: float) -> void:
	$Player/ForwardRay.rotation = $Player.velocity.angle()
	if should_flap():
		$Player.do_flap()


func should_flap() -> bool:
	if is_near_bottom():
		return true
	if $Player/ForwardRay.is_colliding():
		return true
	# if $Player/DownRay.is_colliding():
	# 	return true
	# if $Player/UpRay.is_colliding():
	# 	return false
	# if $Player/StraightRay.is_colliding():
	# 	return true
	return false


func is_near_bottom() -> bool:
	return $Player.position.y >= bottom_edge
