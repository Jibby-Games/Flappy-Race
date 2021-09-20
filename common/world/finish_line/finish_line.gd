extends Node2D


signal finish(player)


func _on_FinishLineArea_body_entered(body: Node) -> void:
	emit_signal("finish", body)
