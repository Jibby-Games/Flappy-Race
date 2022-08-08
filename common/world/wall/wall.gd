extends StaticBody2D


class_name CommonWall


export(PackedScene) var Coin


# Half the height of one of the walls
var half_wall_height = 640
# The gap between the upper and lower walls
var gap = 320 setget set_gap
var players_already_scored := []


func set_gap(size: float) -> void:
	gap = size
	var rect_collider_pos = half_wall_height + (gap / 2)
	$LowerCollider.position.y = rect_collider_pos
	$UpperCollider.position.y = -rect_collider_pos


func _on_PointArea_body_entered(body: Node) -> void:
	if players_already_scored.has(body.name):
		Logger.print(self, "Player %s already scored!" % body.name)
		return
	if body.has_method("add_score"):
		body.add_score()
		players_already_scored.append(body.name)


func spawn_coin() -> void:
	var coin = Coin.instance()
	coin.connect("tree_exiting", self, "_on_Coin_taken")
	add_child(coin)


func _on_Coin_taken() -> void:
	$CoinRespawnTimer.start()


func _on_CoinRespawnTimer_timeout() -> void:
	spawn_coin()
