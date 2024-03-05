extends Area2D

func _on_BotDetector_body_entered(body: Node) -> void:
	if body.has_node("BotController"):
		var bot_controller := body.get_node("BotController")
		bot_controller.target_pos.x = get_parent().global_position.x + get_parent().length
		bot_controller.randomize_target_y_pos()
		# Logger.print(self, "Updated target pos for bot %s to %s" % [body.name, bot_controller.target_pos])
