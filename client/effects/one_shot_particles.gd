extends Particles2D

# How long to wait before destroying the particles to avoid cutting them off
var delay := 1.0
var time := 0.0


func _init() -> void:
	# Force particles to always run even when off screen otherwise they spawn
	# when back on screen which looks odd
	self.set_visibility_rect(Rect2(-INF, -INF, INF, INF))


func _process(delta: float) -> void:
	if not emitting:
		time += delta
		if time > delay:
			queue_free()
