extends Node

signal set_connect_type

func _ready():
	print("Setting IP")
	$MyIP.text = "IP: " + str(IP.get_local_addresses()[6])

func host():
	print("Starting a server")
	Net.initialise_server()
	emit_signal("set_connect_type", true)
