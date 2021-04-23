extends Node


func add_player(player_id):
	var player = Node.new()
	player.set_name(str(player_id))
	add_child(player)


func remove_player(player_id):
	var player = get_node(str(player_id))
	player.queue_free()
