extends Item

export(int) var coin_value := 1

func _do_use(player) -> void:
	player.add_coin(coin_value)
