extends Control

var public_ip: String = ""

onready var ip_label = $IP


func _ready() -> void:
	update_public_ip()


func update_public_ip() -> void:
	$HTTPRequest.request("https://api.ipify.org")


func _on_HTTPRequest_request_completed(
	result: int, response_code: int, headers: PoolStringArray, body: PoolByteArray
) -> void:
	if result == HTTPRequest.RESULT_SUCCESS and response_code == 200:
		# Successful response
		public_ip = body.get_string_from_utf8()
	else:
		Logger.print(
			self,
			(
				"""Unable to determine host IP! HTTP request returned:
result = %d
response_code = %d
headers = %s
body = %s
"""
				% [result, response_code, headers, body.get_string_from_utf8()]
			)
		)
		public_ip = "error"
	ip_label.text = public_ip


func _on_CopyButton_pressed() -> void:
	OS.set_clipboard(public_ip)
	$MessageLabel.show()
	$MessageLabel/MessageTimer.start()


func _on_ShowButton_toggled(button_pressed: bool) -> void:
	ip_label.visible = button_pressed


func _on_MessageTimer_timeout() -> void:
	$MessageLabel.hide()
