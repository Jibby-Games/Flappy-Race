extends Node2D

export(PackedScene) var item_box := preload("res://server/world/spawners/pickups/item_box.tscn")
export(PackedScene) var coin := preload("res://common/world/spawners/pickups/coin.tscn")
export(bool) var spawn_coin := true
export(bool) var change_into_item := true

var spawned_item: Area2D

func _ready() -> void:
	respawn_item()


func _on_item_taken(_body: Node) -> void:
	spawned_item.queue_free()
	$RespawnTimer.start()


func _on_RespawnTimer_timeout() -> void:
	respawn_item()


func respawn_item() -> void:
	if spawn_coin:
		spawn_item(coin)
		if change_into_item:
			spawn_coin = false
	else:
		spawn_item(item_box)


func spawn_item(item: PackedScene) -> void:
	spawned_item = item.instance()
	var result := spawned_item.connect("body_entered", self, "_on_item_taken")
	assert(result == OK)
	add_child(spawned_item)
