extends Node

const RPC_PORT = 31400
const MAX_PLAYERS = 2

var net_id = null
var is_host = false
var peer_ids = []
var current_players = 1
var host_player
var is_online = true


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
