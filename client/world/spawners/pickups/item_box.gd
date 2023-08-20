extends "res://common/world/spawners/pickups/pickup.gd"

export(PackedScene) var ImpactParticles := preload("res://client/effects/impact_particles.tscn")

func _on_item_taken(_body: Node) -> void:
	var particles: Particles2D = ImpactParticles.instance()
	particles.set_modulate(Color.blue)
	particles.set_emitting(true)
	particles.set_lifetime(0.5)
	get_parent().add_child(particles)
