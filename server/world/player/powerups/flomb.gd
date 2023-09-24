extends "res://common/world/player/powerups/flomb.gd"


func _activate() -> void:
	var leader: CommonPlayer = Globals.server_world.get_lead_player()
	var inst: Node2D = flomb_projectile.instance()
	inst.target = leader
	inst.global_position = player.global_position
	Globals.server_world.add_child(inst)
	Network.Server.send_spawn_object(
		0, {"global_position": player.global_position, "target_name": leader.name}
	)
