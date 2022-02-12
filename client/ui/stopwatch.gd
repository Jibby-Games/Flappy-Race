extends Label


var running := false
var time := 0.0


func _process(delta: float) -> void:
	if not running:
		return

	time += delta
	if time >= 3600:
		self.rect_min_size.x = 266
	else:
		self.rect_min_size.x = 198
	self.text = format_time_string(time)


func start() -> void:
	running = true


func stop() -> void:
	running = false


func format_time_string(time_in: float) -> String:
	var minutes := int(fmod(time_in / 60, 60))
	var seconds := int(fmod(time_in, 60))
	var milliseconds := int(fmod(time_in, 1) * 100)
	if time_in >= 3600:
		var hours := int(fmod(time_in / 3600, 60))
		# Hours for all the most dedicated flappy racers
		return "%02d:%02d:%02d.%02d" % [hours, minutes, seconds, milliseconds]
	else:
		return "%02d:%02d.%02d" % [minutes, seconds, milliseconds]


func set_time(time_in: float) -> void:
	time = time_in
	self.text = format_time_string(time)
