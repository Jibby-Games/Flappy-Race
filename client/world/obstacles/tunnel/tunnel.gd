extends "res://common/world/obstacles/tunnel/tunnel.gd"


func set_length(blocks: int) -> void:
	.set_length(blocks)
	$Tunnel/Top/Sprite.region_rect.size.x = blocks * BLOCK_SIZE * 2
	$Tunnel/Bottom/Sprite.region_rect.size.x = $Tunnel/Top/Sprite.region_rect.size.x
