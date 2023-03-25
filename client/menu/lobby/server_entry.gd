extends Control

var ip: String
var port: int


func setup(server_info: Dictionary) -> void:
	$Hbox/Name.text = server_info.get("name", "unknown")
	$Hbox/Players.text = "%d / %d" % [server_info.get("players", "0"), Network.MAX_PLAYERS]
	ip = server_info.get("ip", "")
	port = server_info.get("port", Network.RPC_PORT)


func _on_JoinButton_pressed() -> void:
	Network.Client.start_client(ip, port)
