extends Control

var ip: String
var port: int


func setup(server_info: Dictionary) -> void:
	$Hbox/Name.text = server_info.get("name", "unknown")
	$Hbox/Players.text = "%d / %d" % [server_info.get("players", "0"), Network.MAX_PLAYERS]
	ip = server_info.get("ip", "")
	port = server_info.get("port", Network.RPC_PORT)


func _on_JoinButton_pressed() -> void:
	var join_ip := ip
	if is_official_server_ip(join_ip):
		join_ip = Network.SERVER_MANAGER_URL
	Network.Client.start_client(join_ip, port)


func is_official_server_ip(ip_addr: String) -> bool:
	var hostname: String = Network.SERVER_MANAGER_URL.get_slice("://", 1)
	var official_ip: String = IP.resolve_hostname(hostname, IP.TYPE_IPV4)
	return ip_addr == official_ip
