extends Item

export(int) var coin_value := 10

func _do_use(player) -> void:
	player.add_coin(coin_value)
