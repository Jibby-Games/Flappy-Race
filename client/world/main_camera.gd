extends Camera2D


var _target : Node2D setget set_target


func _process(_delta) -> void:
	if _target and is_instance_valid(_target):
		self.position = _target.position


func set_target(player: Node2D) -> void:
	assert(player, "Camera tried switching to null player")
	_target = player
	Logger.print(self, "Camera target changed to %s!" % [player.get_name()])
