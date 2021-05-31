tool
extends Button


export(String) var label = "Label" setget set_label


func set_label(new_text: String) -> void:
	if label != new_text:
		label = new_text
		$Label.text = new_text
		update()
