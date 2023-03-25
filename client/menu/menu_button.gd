tool
extends Button

export(String) var label = "Label" setget set_label
export(int, "Left", "Center", "Right", "Fill") var alignment setget set_alignment


func set_label(new_text: String) -> void:
	if label != new_text:
		label = new_text
		$Label.text = new_text
		update()


func set_alignment(new_align: int) -> void:
	if alignment != new_align:
		alignment = new_align
		$Label.align = new_align
		update()
