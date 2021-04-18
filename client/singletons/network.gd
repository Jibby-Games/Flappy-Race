extends Node

const RPC_PORT = 31400
const MAX_PLAYERS = 4

signal public_ip_changed(new_ip)

var net_id = null
var is_host = false
var peer_ids = []
var current_players = 1
var host_player
var is_online = true
var public_ip = "127.0.0.1"


func initialise_server():
	is_host = true

	# This starts the actual server to communicate with clients
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(RPC_PORT, MAX_PLAYERS)
	get_tree().network_peer = peer

	is_online = true


func initialise_client(server_ip):
	is_host = false

	# Start a client for communicating with the server, and connect to that server
	var peer = NetworkedMultiplayerENet.new()
	peer.create_client(server_ip, RPC_PORT)
	get_tree().network_peer = peer

	is_online = true


func set_ids():
	if is_online:
		net_id = get_tree().get_network_unique_id()
		peer_ids = get_tree().get_network_connected_peers()
	else:
		net_id = 0
		peer_ids = []


func update_public_ip():
	var ip_lookup_api = "https://api.ipify.org"
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.connect("request_completed", self, "_http_request_completed")
	http_request.request(ip_lookup_api)


func _http_request_completed(_result, response_code, _headers, body):
	if response_code == 200:
		# Successful response
		public_ip = body.get_string_from_utf8()
	else:
		print("[NET] Received HTTP response code ", response_code, " when finding public IP!")
		public_ip = "localhost"
	emit_signal("public_ip_changed", public_ip)
