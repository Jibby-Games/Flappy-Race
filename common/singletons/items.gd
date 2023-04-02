extends Node

export(Array) var items = [
	preload("res://common/singletons/items/gem/gem.tres"),
	preload("res://common/singletons/items/picoberry/picoberry.tres"),
	preload("res://common/singletons/items/invisiberry/invisiberry.tres"),
]


func pick_item() -> Item:
	var index = randi() % items.size()
	return items[index]
