extends Control

var hint_text := ""
var dots := ""
var timer := Timer.new()

onready var progress := $CenterContainer/VBoxContainer/ProgressBar
onready var loading_hint := $CenterContainer/VBoxContainer/LoadingHint


func start() -> void:
	self.show()
	var result := timer.connect("timeout", self, "_on_timer_timeout")
	assert(result == OK)
	timer.set_wait_time(0.5)
	add_child(timer)
	timer.start()
	dots = ""
	loading_hint.text = hint_text


func set_progress(percent: float) -> void:
	progress.set_value(percent)


func _on_timer_timeout() -> void:
	if dots == "...":
		dots = ""
	else:
		dots += "."
	loading_hint.text = "%s%s" % [hint_text, dots]


func stop() -> void:
	timer.stop()
	self.hide()
