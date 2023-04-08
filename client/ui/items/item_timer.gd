extends CenterContainer

var item_id := -1
var start_time := 1.0
var timeleft := 1.0


func _ready() -> void:
	timeleft = start_time


func setup(icon: Texture, duration: int) -> void:
	# self.item_id = new_item_id
	# self.set_name(str(item_id))
	$Icon.texture = icon
	start_time = duration
	timeleft = duration


func _process(delta: float) -> void:
	if timeleft <= 0:
		self.queue_free()
	timeleft -= delta
	$Progress.value = timeleft / start_time
