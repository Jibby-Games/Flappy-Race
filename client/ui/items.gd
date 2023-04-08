extends Control

const SHUFFLES = 10


func get_item(item: Item) -> void:
	shuffle_items(item)
	$AnimationPlayer.stop()
	$AnimationPlayer.play("get_item")


func shuffle_items(item: Item) -> void:
	var start_point: int = randi() % Items.items.size()
	for i in SHUFFLES:
		yield(get_tree().create_timer(0.1), "timeout")
		var index = (start_point + i) % Items.items.size()
		$ItemSelector.texture = Items.get_item(index).icon
	yield(get_tree().create_timer(0.1), "timeout")
	$ItemSelector.texture = item.icon
