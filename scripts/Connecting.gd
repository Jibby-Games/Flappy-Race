extends ColorRect

const CONNECT_TEXT = ["Waiting for players...", "Connecting to server..."]


func set_connect_type(host):
	show()
	if host:
		$ConnectingText.text = CONNECT_TEXT[0]
	else:
		$ConnectingText.text = CONNECT_TEXT[1]
	
