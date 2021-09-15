extends Node

class_name Logger

static func print(self_node: Node, message: String, args: Array = []) -> void:
	var time = OS.get_datetime()
	var time_string = "%02d:%02d:%02d" % [time.hour, time.minute, time.second]
	var node_path = str(self_node.get_path()).trim_prefix("/root/")
	var formatted_msg = message % args
	print("%s [%s] %s" % [time_string, node_path, formatted_msg])
