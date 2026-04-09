extends Control

var game_id: String = "" setget set_game_id

onready var game_id_label = $GameId

func _on_CopyButton_pressed() -> void:
	Globals.copy_to_clipboard(game_id)
	$MessageLabel.show()
	$MessageLabel/MessageTimer.start()


func _on_ShowButton_toggled(button_pressed: bool) -> void:
	game_id_label.visible = button_pressed


func _on_MessageTimer_timeout() -> void:
	$MessageLabel.hide()


func set_game_id(new_game_id: String) -> void:
	game_id = new_game_id
	game_id_label.text = game_id
