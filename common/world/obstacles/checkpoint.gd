extends Area2D


func _on_Checkpoint_body_entered(body: Node) -> void:
	body.checkpoint_position = global_position
	Logger.print(self, "Set player %s checkpoint to %s", [body.name, body.checkpoint_position])
