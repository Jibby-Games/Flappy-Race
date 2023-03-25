extends Area2D


func _on_Checkpoint_body_entered(body: Node) -> void:
	if body.checkpoint_position == global_position:
		# Already set this checkpoint
		return
	body.checkpoint_position = global_position
	Logger.print(self, "Set player %s checkpoint to %s", [body.name, body.checkpoint_position])
