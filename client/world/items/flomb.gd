extends "res://common/world/items/flomb.gd"

export(PackedScene) var explosion_effect = preload("res://client/effects/explosion/explosion.tscn")

func explode() -> void:
	$Sprite.hide()
	# Spawn an explosion
	var inst: Node2D = explosion_effect.instance()
	inst.global_position = self.global_position
	world.add_child(inst)
	.explode()
