extends Node

signal show_connect_screen

# Called when the button is loaded.
func _ready():
	var myIP
	# TODO: Is this reliable, and portable between OS?
	for ip in IP.get_local_addresses():
		if (not ip.begins_with("127")) and ip.count(".") == 3:
			myIP = ip
	$MyIP.text = "IP: " + str(myIP)


# Tell the game to start hosting. Connected to the pressed() signal
func on_Host_pressed():
	# Call the netcode that does the legwork
	Net.initialise_server()
	# And tell the connecting waitscreen to show itself
	emit_signal("show_connect_screen", 0)
