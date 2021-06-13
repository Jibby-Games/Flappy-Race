extends HBoxContainer


var public_ip: String = ""


func _ready():
	update_public_ip()


func update_public_ip() -> void:
	$HTTPRequest.request("https://api.ipify.org")


func _on_HTTPRequest_request_completed(_result, response_code, _headers, body) -> void:
	if response_code == 200:
		# Successful response
		public_ip = body.get_string_from_utf8()
	else:
		print("[%s] Received HTTP response code %s when finding public IP!" % [get_path().get_name(1), response_code])
		public_ip = "error"
	$IP.text = public_ip


func _on_CopyButton_pressed() -> void:
	OS.set_clipboard(public_ip)
