extends Powerup

var attraction := 1
# Stores the cumulative attraction force so items accelerate towards the player
var captured_items := {}


func _ready() -> void:
	$Area2D.monitoring = false


func _activate() -> void:
	$Area2D.monitoring = true
	# Add all areas that already overlap
	for area in $Area2D.get_overlapping_areas():
		captured_items[area] = 0


func _deactivate() -> void:
	$Area2D.monitoring = false
	captured_items.clear()


func _on_Area2D_area_entered(area: Area2D) -> void:
	captured_items[area] = 0


func _on_Area2D_area_exited(area: Area2D) -> void:
	# warning-ignore:return_value_discarded
	captured_items.erase(area)


func _physics_process(delta: float) -> void:
	for item in captured_items.keys():
		item.global_position = lerp(
			item.global_position, self.global_position, captured_items[item]
		)
		captured_items[item] += delta * attraction
		if captured_items[item] > 1.0:
			# warning-ignore:return_value_discarded
			captured_items.erase(item)
