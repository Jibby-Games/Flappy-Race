extends Camera2D


# Shake parameters
export(float, 0, 1) var decay = 0.8  # How quickly the shaking stops [0, 1].
export(Vector2) var max_offset = Vector2(100, 75)  # Maximum hor/ver shake in pixels.
export(float, 0, 1) var max_roll = 0.1  # Maximum rotation in radians (use sparingly).
export (NodePath) var initial_target  # Assign the node this camera will follow.


onready var noise := OpenSimplexNoise.new()

var noise_y = 0
var trauma := 0.0  # Current shake strength.
var trauma_power := 2  # Trauma exponent. Use [2, 3].


var speed := 5.0
var _target : Node2D setget set_target
# The offset relative to the viewport size, 0.0 = centred
var offset_ratio := 0.333
var camera_x_offset := 640
var velocity := Vector2.ZERO


func _ready() -> void:
	randomize()
	noise.seed = randi()
	noise.period = 4
	noise.octaves = 2
	if initial_target:
		_target = get_node(initial_target)
	camera_x_offset = int(get_viewport_rect().size.x * offset_ratio)
	offset.x = camera_x_offset


func add_trauma(amount: float) -> void:
	trauma = min(trauma + amount, 1.0)


# Only move the camera in the physics process to stop jittery objects
func _physics_process(delta: float) -> void:
	if _target and is_instance_valid(_target):
		global_position = lerp(global_position, _target.global_position, delta*speed)
	else:
		global_position += velocity


func _process(delta: float) -> void:
	if trauma:
		trauma = max(trauma - decay * delta, 0)
		shake()


func shake() -> void:
	var amount = pow(trauma, trauma_power)
	noise_y += 1
	rotation = max_roll * amount * noise.get_noise_2d(noise.seed, noise_y)
	offset.x = camera_x_offset + max_offset.x * amount * noise.get_noise_2d(noise.seed*2, noise_y)
	offset.y = max_offset.y * amount * noise.get_noise_2d(noise.seed*3, noise_y)


func set_target(player: Node2D) -> void:
	assert(player, "Camera tried switching to null player")
	_target = player
	Logger.print(self, "Camera target changed to %s!" % [player.get_name()])
