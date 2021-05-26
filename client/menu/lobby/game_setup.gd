extends Control


var public_ip: String = ""


func _ready() -> void:
	update_public_ip()
	assert(multiplayer.connect("network_peer_disconnected", self, "remove_player") == OK)


func update_public_ip() -> void:
	$HTTPRequest.request("https://api.ipify.org")


func _on_HTTPRequest_request_completed(_result, response_code, _headers, body) -> void:
	if response_code == 200:
		# Successful response
		public_ip = body.get_string_from_utf8()
	else:
		print("[NET] Received HTTP response code ", response_code, " when finding public IP!")
		public_ip = "error"
	$HBoxContainer/IP.text = public_ip


func _on_CopyButton_pressed() -> void:
	OS.set_clipboard(public_ip)


func add_player(player_id: int) -> void:
	var player = Label.new()
	player.set_name(str(player_id))
	player.text = str(player_id)
	$PlayerList.add_child(player)


func remove_player(player_id: int) -> void:
	var player = $PlayerList.get_node(str(player_id))
	player.queue_free()


func populate_players(players: PoolIntArray) -> void:
	print("[CNT]: Got player list: %s" % players)
	clear_players()
	for player in players:
		add_player(player)


func clear_players() -> void:
	for child in $PlayerList.get_children():
		child.queue_free()


func _on_BackButton_pressed() -> void:
	Network.Client.stop_client()
	Network.Server.stop_server()
	Network.Client.change_scene("res://client/menu/lobby/lobby.tscn")


func _on_StartButton_pressed() -> void:
	Network.Client.send_start_game_request()
