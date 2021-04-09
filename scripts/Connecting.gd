extends ColorRect

const CONNECT_TEXT = ["Waiting for players...", "Connecting to server..."]


func set_connect_type(host):
	show()
	if host:
		$ConnectingText.text = CONNECT_TEXT[0]
		var myIP
		for ip in IP.get_local_addresses():
			if (not ip.begins_with("127")) and ip.count(".") == 3:
				print(ip)
				myIP = ip
		$MyIP.text = "IP: " + str(myIP)

	else:
		$ConnectingText.text = CONNECT_TEXT[1]
	
