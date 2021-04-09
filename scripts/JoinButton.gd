extends Button

signal set_connect_type

func _on_Join_pressed():
	if $JoinIP.text.is_valid_ip_address():
		$InvalidIP.hide()
		join()
	else:
		$InvalidIP.show()

func join():
	var join_ip = $JoinIP.text
	Net.initialise_client(join_ip)
	emit_signal("set_connect_type", false)
