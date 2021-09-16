extends Control


var public_ip: String = ""


onready var ip_label = $IP


func _ready() -> void:
	update_public_ip()


func update_public_ip() -> void:
	$HTTPRequest.request("https://api.ipify.org")


func _on_HTTPRequest_request_completed(result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray) -> void:
		# Successful response
		public_ip = body.get_string_from_utf8()
	else:
		Logger.print(self, "Received HTTP response code %s when finding public IP!" % [response_code])
		public_ip = "error"
	ip_label.text = public_ip


func _on_CopyButton_pressed() -> void:
	OS.set_clipboard(public_ip)
	$MessageLabel.show()
	$MessageLabel/MessageTimer.start()


func _on_ShowButton_toggled(button_pressed) -> void:
	ip_label.visible = button_pressed


func _on_MessageTimer_timeout() -> void:
	$MessageLabel.hide()
