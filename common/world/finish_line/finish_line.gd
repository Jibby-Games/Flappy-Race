extends Node2D


var players_already_finished := []


func _on_FinishLineArea_body_entered(body: Node) -> void:
	if players_already_finished.has(body.name):
		Logger.print(self, "Player %s already finished!" % body.name)
		return
	if body.has_method("finish"):
		body.finish()
		players_already_finished.append(body.name)
