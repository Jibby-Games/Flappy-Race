extends CenterContainer

var start_time := 1.0
var timeleft := 1.0


func _ready() -> void:
	timeleft = start_time


func setup(item_name: String, icon: Texture, duration: int) -> void:
	self.set_name(item_name)
	$Icon.texture = icon
	set_duration(duration)


func set_duration(duration: int) -> void:
	start_time = duration
	timeleft = duration


func _process(delta: float) -> void:
	if timeleft <= 0:
		self.queue_free()
	timeleft -= delta
	$Progress.value = timeleft / start_time
