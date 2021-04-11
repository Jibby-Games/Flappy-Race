extends Button

signal show_connect_screen


# Connected to the pressed() signal.
func _on_Join_pressed():
	if $JoinIP.text.is_valid_ip_address():
		$InvalidIP.hide()
		join()
	else:
		$InvalidIP.show()

func join():
	var join_ip = $JoinIP.text
	# Ask the netcode to start up the client
	Net.initialise_client(join_ip)
	# and display the waiting screen
	emit_signal("show_connect_screen", 1)
