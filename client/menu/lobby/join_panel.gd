extends PopupPanel

onready var error_message = $MarginContainer/VBoxContainer/ErrorMessage
onready var info_message = $MarginContainer/VBoxContainer/InfoMessage
onready var ip_input = $MarginContainer/VBoxContainer/IpContainer/IpInput

var use_code := false setget set_use_code

func set_use_code(value: bool) -> void:
	use_code = value
	if use_code:
		ip_input.placeholder_text = "Enter Join Code"
		ip_input.text = ""
		ip_input.hint_tooltip = "The join code for the game you want to join."
	else:
		ip_input.placeholder_text = "Enter IP:Port"
		ip_input.text = "127.0.0.1"
		ip_input.hint_tooltip = "The IP address and/or port to connect to."

func try_join() -> void:
	if ip_input.text.empty():
		if use_code:
			show_error("Please enter a join code")
		else:
			show_error("Please enter an IP")
		return
	show_info("Connecting...")
	if use_code:
		var url := Network.get_game_url(ip_input.text)
		$ConnectionTimer.start()
		Network.Client.start_client(url)
	else:
		var join_ip: String = ip_input.text
		var port := Network.RPC_PORT
		var protocol := "ws"
		# Parse the protocol
		if "://" in join_ip:
			var parts = join_ip.split("://")
			protocol = parts[0]
			join_ip = parts[1]
		# Parse the port
		if ":" in join_ip:
			var parts = join_ip.split(":")
			join_ip = parts[0]
			port = int(parts[1])
		$ConnectionTimer.start()
		var url := "%s://%s" % [protocol, join_ip]
		Network.Client.start_client(url, port)


func show_info(message: String) -> void:
	error_message.hide()
	info_message.text = message
	info_message.show()


func show_error(message: String) -> void:
	info_message.hide()
	error_message.text = message
	error_message.show()


func _on_ConnectionTimer_timeout() -> void:
	show_error("Connection failed!")
	Network.Client.stop_client()


func _on_JoinButton_pressed() -> void:
	try_join()


func _on_IpInput_text_entered(_new_text: String) -> void:
	try_join()


func _on_JoinPanel_about_to_show() -> void:
	$ConnectionTimer.stop()
	error_message.hide()
	info_message.hide()
