extends CommonPlayer


func _process(_delta: float) -> void:
	# Debug tools
	# Must be done in process since _input can't receive events on the server viewport for some reason
	if ProjectSettings.get_setting("application/config/debug_tools") and not is_bot:
		for key in range(KEY_1, KEY_9 + 1):
			if Input.is_physical_key_pressed(key):
				var item_id: int = key - KEY_1
				if item_id < Items.items.size():
					add_item(Items.get_item(item_id))
					Network.Server.send_player_add_item(int(self.name), item_id)
