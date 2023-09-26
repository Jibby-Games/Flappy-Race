extends MarginContainer

var current_coins := 0

func _ready() -> void:
	$HBoxContainer/Control/AnimatedSprite.play("spin")


func update_coins(amount: int) -> void:
	var diff := amount - current_coins
	if diff > 0:
		$CoinUpdate.text = "+%d" % diff
		$AnimationPlayer.stop()
		$AnimationPlayer.play("add_coins")
	else:
		$CoinUpdate.text = "%d" % diff
		$AnimationPlayer.stop()
		$AnimationPlayer.play("remove_coins")
	current_coins = amount
	$HBoxContainer/Coins.text = "%d" % amount
