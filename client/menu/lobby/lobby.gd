extends Control


const MAX_CONNECT_TIME := 5


func _ready() -> void:
	assert(multiplayer.connect("connected_to_server", self, "_on_connected") == OK)


func _on_BGMusic_finished():
	$BGMusic.play()


func _on_Back_pressed():
	Network.Client.change_scene("res://client/menu/title/title_screen.tscn")


func on_Host_pressed():
	Network.start_multiplayer_host()
	Network.Client.change_scene("res://client/menu/lobby/game_setup.tscn")


# Connected to the pressed() signal.
func _on_Join_pressed():
	$ErrorMessage.text = "Connecting..."
	$ErrorMessage.show()
	var join_ip = $Join/JoinIP.text
	if join_ip.is_valid_ip_address():
		$Join/InvalidIP.hide()
		try_connect_to_server(join_ip)
	else:
		$Join/InvalidIP.show()

func try_connect_to_server(ip: String):
	$ConnectionTimer.start(MAX_CONNECT_TIME)
	Network.Client.start_client(ip, Network.RPC_PORT)


func _on_connected() -> void:
	$ConnectionTimer.stop()
	Network.Client.change_scene("res://client/menu/lobby/game_setup.tscn")


func _on_ConnectionTimer_timeout():
	print("[%s] Connection timed out!" % [get_path().get_name(1)])
	Network.Client.stop_client()
	$ErrorMessage.text = "Failed to connect!"
	$ErrorMessage.show()
