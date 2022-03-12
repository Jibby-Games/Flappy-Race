extends Node2D


signal finish(player)


var players_already_finished := []


func _on_FinishLineArea_body_entered(body: Node) -> void:
	if players_already_finished.has(body.name):
		Logger.print(self, "Player %s already finished!" % body.name)
		return
	if body.has_method("add_score"):
		body.add_score()
		players_already_finished.append(body.name)
	emit_signal("finish", body)
