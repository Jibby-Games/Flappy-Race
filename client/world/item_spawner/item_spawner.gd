extends "res://common/world/item_spawner/item_spawner.gd"

export(PackedScene) var ImpactParticles := preload("res://client/effects/impact_particles.tscn")


func _on_Item_body_entered(body: Node) -> void:
	._on_Item_body_entered(body)
	var particles: Particles2D = ImpactParticles.instance()
	particles.set_modulate(Color.blue)
	particles.set_emitting(true)
	particles.set_lifetime(0.5)
	add_child(particles)
