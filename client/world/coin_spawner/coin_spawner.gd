extends "res://common/world/coin_spawner/coin_spawner.gd"

export(PackedScene) var ImpactParticles := preload("res://client/effects/impact_particles.tscn")


func _on_Coin_body_entered(body: Node) -> void:
	._on_Coin_body_entered(body)
	var particles: Particles2D = ImpactParticles.instance()
	particles.set_modulate(Color.gold)
	particles.set_emitting(true)
	particles.set_lifetime(0.5)
	add_child(particles)
