extends "res://common/world/item_spawner/item_spawner.gd"

func _on_Item_body_entered(body: Node) -> void:
	._on_Item_body_entered(body)
	if body.has_method("add_item"):
		var leader := Globals.server_world.get_lead_player()
		var dist_to_leader: float = leader.global_position.x - body.global_position.x
		var item_id = Items.pick_item_id(dist_to_leader)
		var item = Items.get_item(item_id)
		body.add_item(item)
		Network.Server.send_player_add_item(int(body.name), item_id)
