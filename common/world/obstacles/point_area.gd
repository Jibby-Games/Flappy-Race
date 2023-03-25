extends Area2D

var players_already_scored := []


func _on_PointArea_body_entered(body: Node) -> void:
	if players_already_scored.has(body.name):
		Logger.print(self, "Player %s already scored!" % body.name)
		return
	if body.has_method("add_score"):
		body.add_score()
		players_already_scored.append(body.name)
