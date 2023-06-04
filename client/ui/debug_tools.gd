extends Control


func _ready() -> void:
	if not ProjectSettings.get_setting("application/config/debug_tools"):
		hide()
		return
	# Show items with number keys
	var i := 1
	for item in Items.items:
		var debug_key := Button.new()
		debug_key.text = "%d" % i
		debug_key.icon = item.icon
		$HBoxContainer.add_child(debug_key)
		i += 1
