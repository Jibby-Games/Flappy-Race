extends Control


export(PackedScene) var fading_label := preload("res://client/ui/fading_label.tscn")
export(int) var message_limit := 6

var messages := []

func _ready() -> void:
	var result := Network.Client.connect("player_list_changed", self, "_on_player_list_changed")
	assert(result == OK)


func _on_player_list_changed(old_player_list: Dictionary, new_player_list: Dictionary) -> void:
	if old_player_list.empty():
		# Don't announce changes the first time players are populated (for first time joiners)
		return
	announce_player_changes(old_player_list, new_player_list)


func add_message(msg: String):
	if messages.size() >= message_limit:
		var last_msg: Node = messages.pop_front()
		if is_instance_valid(last_msg):
			last_msg.fade_out()
	var new_msg := fading_label.instance()
	new_msg.text = msg
	messages.append(new_msg)
	$VBoxContainer.add_child(new_msg)


func announce_player_changes(old_player_list: Dictionary, new_player_list: Dictionary) -> void:
	for player_id in new_player_list:
		if not player_id in old_player_list:
			add_message("%s joined the game" % new_player_list[player_id]["name"])
	for player_id in old_player_list:
		if not player_id in new_player_list:
			add_message("%s left the game" % old_player_list[player_id]["name"])
