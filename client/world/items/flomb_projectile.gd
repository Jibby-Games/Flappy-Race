extends "res://common/world/items/flomb_projectile.gd"

export(PackedScene) var explosion_effect = preload("res://client/effects/explosion/explosion.tscn")

func _ready() -> void:
	$AnimatedSprite.play()


func explode() -> void:
	$AnimatedSprite.hide()
	# Spawn an explosion
	var inst: Node2D = explosion_effect.instance()
	inst.global_position = self.global_position
	world.add_child(inst)
	.explode()
