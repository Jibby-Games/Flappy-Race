extends Control


export(PackedScene) var fading_label := preload("res://client/ui/fading_label.tscn")


func add_message(msg: String):
	var inst := fading_label.instance()
	inst.text = msg
	$VBoxContainer.add_child(inst)
