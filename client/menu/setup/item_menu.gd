extends MenuButton

var popup: PopupMenu

func _ready() -> void:
	popup = self.get_popup()
	popup.clear()
	popup.hide_on_checkable_item_selection = false
	popup.connect("index_pressed", self, "_on_item_menu_index_pressed")
	for i in Items.items.size():
		var item = Items.get_item(i)
		popup.add_icon_check_item(item.icon, item.name)
		popup.set_item_checked(i, true)


func _on_item_menu_index_pressed(idx: int) -> void:
	# Don't allow all items to be disabled
	# Allow checking any unchecked item, but prevent unchecking the last checked one
	if not popup.is_item_checked(idx) or more_than_one_checked():
		popup.toggle_item_checked(idx)
		Network.Client.send_item_menu_change(idx, popup.is_item_checked(idx))


func more_than_one_checked() -> bool:
	var checked = 0
	for i in popup.get_item_count():
		if popup.is_item_checked(i):
			checked += 1;
			if checked > 1:
				return true
	return false
