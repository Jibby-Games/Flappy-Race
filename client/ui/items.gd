extends Control

const SHUFFLES = 10

export(PackedScene) var item_timer := preload("res://client/ui/items/item_timer.tscn")

var next_item: Item

func _ready() -> void:
	var result := $AnimationPlayer.connect("animation_finished", self, "use_item")
	assert(result == OK)


func get_item(item: Item) -> void:
	next_item = item
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


func use_item(anim_name: String) -> void:
	if anim_name == "get_item" and next_item.duration > 0:
		for item in $ActiveItems.get_children():
			if item.name == next_item.name:
				# This item is already active, so just reset it's duration
				item.set_duration(next_item.duration)
				return
		# This is an active item which needs a timer
		var new_item := item_timer.instance()
		new_item.setup(next_item.name, next_item.icon, next_item.duration)
		$ActiveItems.add_child(new_item)
