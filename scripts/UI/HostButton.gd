extends Node

signal show_connect_screen


# Tell the game to start hosting. Connected to the pressed() signal
func on_Host_pressed():
	# Call the netcode that does the legwork
	Net.initialise_server()
	# And tell the connecting waitscreen to show itself
	emit_signal("show_connect_screen", 0)
