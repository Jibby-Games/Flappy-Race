extends ColorRect

enum ConnTypes {HOST=0, CLIENT=1}

# This function is called when the join or host buttons are pushed.
# It should ONLY handle changing the screen for the user.
func show_connect_screen(conn_type):
	# Reveal thyself
	show()
	
	if conn_type == ConnTypes.HOST:
		$ConnectingText.text = "Waiting for players..."
		$NumPlayers.text = "Players: [%d/%d]" % [Net.current_players, Net.MAX_PLAYERS]
		var myIP = Net.get_my_ip()
		$MyIP.text = "IP: %s" % str(myIP)
		$MyIP.show()
		$Start.show()
		$NumPlayers.show()
	
	elif conn_type == ConnTypes.CLIENT:
		$ConnectingText.text = "...Connecting to server..."
