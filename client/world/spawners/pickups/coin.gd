extends "res://common/world/spawners/pickups/coin.gd"

export(PackedScene) var ImpactParticles := preload("res://client/effects/impact_particles.tscn")

func _on_item_taken(body: Node) -> void:
	._on_item_taken(body)
	var particles: Particles2D = ImpactParticles.instance()
	particles.set_modulate(Color.gold)
	particles.set_emitting(true)
	particles.set_lifetime(0.5)
	get_parent().add_child(particles)
