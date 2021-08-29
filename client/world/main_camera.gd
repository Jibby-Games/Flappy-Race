extends Camera2D


var _target : Node2D setget set_target


func _process(_delta):
	if _target and is_instance_valid(_target):
		self.position = _target.position


func set_target(player: Node2D) -> void:
	assert(player, "Camera tried switching to null player")
	_target = player
	print("[%s] Camera target changed to %s!" % [get_path().get_name(1), player.get_name()])
