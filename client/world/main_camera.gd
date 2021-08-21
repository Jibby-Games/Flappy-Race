extends Camera2D


var target : Node2D


func _process(_delta):
	if target and is_instance_valid(target):
		self.position = target.position
