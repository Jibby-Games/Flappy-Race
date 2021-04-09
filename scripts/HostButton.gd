extends Node

signal set_connect_type

func _ready():
	print("Setting IP")
	var myIP
	for ip in IP.get_local_addresses():
		if (not ip.begins_with("127")) and ip.count(".") == 3:
			print(ip)
			myIP = ip
	$MyIP.text = "IP: " + str(myIP)

func host():
	print("Starting a server")
	Net.initialise_server()
	emit_signal("set_connect_type", true)
