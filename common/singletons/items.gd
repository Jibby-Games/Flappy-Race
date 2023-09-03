extends Node

class ItemWeights:
	var item_ids := []
	var weights := []
	var weights_sum := 0

	func add_item_weight(id, weight) -> void:
		item_ids.append(id)
		weights.append(weight)
		weights_sum += weight


	func _to_string() -> String:
		var item_list := ""
		for i in item_ids.size():
			item_list += "%s (%d) " % [Items.items[item_ids[i]].name, weights[i]]
		return "%s(sum: %s)" % [item_list, weights_sum]


	func pick_weighted_random_item_id() -> int:
		var rand_num: int = randi() % weights_sum
		for i in weights.size():
			if rand_num < weights[i]:
				return item_ids[i]
			rand_num -= weights[i]
		assert(false, "Failed to pick a random weighted choice")
		return 0


# All items used in game, the position in the array will be the item ID
export(Array) var items = [
	preload("res://common/singletons/items/coin/coin.tres"),
	preload("res://common/singletons/items/gem/gem.tres"),
	preload("res://common/singletons/items/picoberry/picoberry.tres"),
	preload("res://common/singletons/items/invisiberry/invisiberry.tres"),
	preload("res://common/singletons/items/magnet/magnet.tres"),
	preload("res://common/singletons/items/laser/laser.tres"),
	preload("res://common/singletons/items/boost/boost.tres"),
]

var distance_item_weights := {}

func _ready() -> void:
	calculate_item_weights_for_distances()


func calculate_item_weights_for_distances() -> void:
	Logger.print(self, "Calculating item weights...")
	for id in items.size():
		var item: Item = items[id]
		for distance in item.distance_weights:
			var weight_for_dist: int = item.distance_weights[distance]
			if weight_for_dist <= 0:
				# This item isn't available at this distance so don't add it
				continue
			if not distance in distance_item_weights:
				distance_item_weights[distance] = ItemWeights.new()
			distance_item_weights[distance].add_item_weight(id, item.distance_weights[distance])
	for distance in distance_item_weights:
		Logger.print(self, "Distance: %d - %s" % [distance, distance_item_weights[distance]])


func pick_item_id(dist_to_leader: float) -> int:
	var highest_dist := get_highest_available_distance(dist_to_leader)
	Logger.print(self, "Picking item with distance = %f, highest_dist = %d, item_weights = %s" % [dist_to_leader, highest_dist, distance_item_weights[highest_dist]])
	var item_id = distance_item_weights[highest_dist].pick_weighted_random_item_id()
	return item_id


func get_highest_available_distance(dist_to_leader: float) -> int:
	var highest_dist := 0
	for distance in distance_item_weights.keys():
		if dist_to_leader > distance and distance > highest_dist:
			# Find the highest distance in the weight tables
			highest_dist = distance
	return highest_dist


func get_item(id: int) -> Item:
	if id >= items.size():
		push_error("Item ID %d doesn't exist! Max ID = %d" % [id, items.size()])
		return null
	return items[id]
