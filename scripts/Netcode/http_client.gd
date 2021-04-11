extends HTTPRequest


func get_public_ip():
	var ip_lookup_api = "https://api.ipify.org"

	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.connect("request_completed", self, "_http_request_completed")
	http_request.request(ip_lookup_api)

func _http_request_completed(result, response_code, headers, body):
	Net.public_ip = body.get_string_from_utf8()
