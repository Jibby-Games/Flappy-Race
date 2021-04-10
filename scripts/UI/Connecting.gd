extends ColorRect


# This function is called when the join or host buttons are pushed.
# It should ONLY handle changing the screen for the user.
func show_connect_screen(conn_type):
	# conn_type indexes what kind of splash screen we show to the user.
	# 0: Host
	# 1: Client
	# 2: Spectator ## TODO
	# 
	# Should allow for some degree of expansion.
	
	
	# Reveal thyself
	show()
	# Host
	if conn_type == 0:
		$ConnectingText.text = "Waiting for players..."
		var myIP = '127.0.0.1'
		for ip in IP.get_local_addresses():
			if (not ip.begins_with("127")) and ip.count(".") == 3:
				print(ip)
				myIP = ip
		$MyIP.text = "IP: " + str(myIP)
		$MyIP.show()
	# Client
	elif conn_type == 1:
		$ConnectingText.text = "...Connecting to server..."
