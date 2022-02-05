extends Node


class_name UpnpHandler


var upnp : UPNP = null
var add_thread : Thread = null
var remove_thread : Thread = null
var port := 0
var port_description : String = ProjectSettings.get_setting("application/config/name")


func _init() -> void:
	upnp = UPNP.new()


func try_add_port_mapping(server_port: int) -> void:
	if add_thread != null and add_thread.is_active():
		add_thread.wait_to_finish()
	add_thread = Thread.new()
	var result = add_thread.start(self, "_add_port", server_port)
	if result != OK:
		push_error("Unable to start UPnP add port forward thread. Error code: %s" % [result])


func _add_port(server_port: int) -> void:
	Logger.print(self, "Attempting to forward port %d", [server_port])
	# UPNP queries take some time.
	var result: int = upnp.discover()
	if result != UPNP.UPNP_RESULT_SUCCESS:
		push_error("UPNP discover error code: %s" % [result])
		return

	var gateway = upnp.get_gateway()
	if gateway == null:
		push_error("No UPnP gateway found")
		return
	if gateway.is_valid_gateway() == false:
		push_error("UPnP gateway is not valid")
		return

	# Try 24 hour duration by default.
	var duration = 24 * 60 * 60
	result = gateway.add_port_mapping(server_port, server_port, port_description, "UDP", duration)
	if result == UPNP.UPNP_RESULT_ONLY_PERMANENT_LEASE_SUPPORTED:
		Logger.print(self, "Only permanent lease supported. Trying permanent lease.")
		result = gateway.add_port_mapping(server_port, server_port, port_description)

	if result == UPNP.UPNP_RESULT_SUCCESS:
		Logger.print(self, "Successfully forwarded port %d", [server_port])
		port = server_port
	else:
		push_error("UPnP add port error code: %s" % [result])


func _notification(what) -> void:
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		if add_thread != null:
			Logger.print(self, "Waiting for UPNP add port thread to finish.")
			add_thread.wait_to_finish()
		remove_port_mapping()
		if remove_thread != null:
			Logger.print(self, "Waiting for UPNP remove port thread to finish.")
			remove_thread.wait_to_finish()


func remove_port_mapping() -> void:
	if port == 0:
		# No port forwarded
		return
	if remove_thread != null and remove_thread.is_active():
		remove_thread.wait_to_finish()
		# Removal already in progress
		return
	remove_thread = Thread.new()
	var result = remove_thread.start(self, "_remove_port", port)
	if result != OK:
		push_error("Unable to start UPnP remove port forward thread. Error code: %s" % [result])


func _remove_port(server_port: int) -> void:
	Logger.print(self, "UPnP port forwarding removal started.")
	var result := upnp.delete_port_mapping(server_port)
	if result == upnp.UPNP_RESULT_SUCCESS:
		port = 0
		Logger.print(self, "Successfully removed port %d", [server_port])
	else:
		push_error("UPnP remove port error code: %s" % [result])
	queue_free()
