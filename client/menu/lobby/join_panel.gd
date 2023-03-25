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
	if ":" in join_ip:
		var parts = join_ip.split(":")
		join_ip = parts[0]
		port = int(parts[1])
	$ConnectionTimer.start()
	Network.Client.start_client(join_ip, port)


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
