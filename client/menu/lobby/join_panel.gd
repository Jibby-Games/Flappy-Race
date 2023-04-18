extends PopupPanel

onready var error_message = $MarginContainer/VBoxContainer/ErrorMessage
onready var info_message = $MarginContainer/VBoxContainer/InfoMessage
onready var ip_input = $MarginContainer/VBoxContainer/IpContainer/IpInput


func _on_JoinButton_pressed() -> void:
	if ip_input.text.empty():
		show_error("Please enter an IP")
		return
	show_info("Connecting...")
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
