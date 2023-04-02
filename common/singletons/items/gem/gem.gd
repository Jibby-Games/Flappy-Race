extends Item

export(int) var coin_value := 10

func use(player) -> void:
	player.add_coin(coin_value)
