extends Label

const FADE_DELAY := 2.5


func _ready() -> void:
	$DelayTimer.start(FADE_DELAY)


func _on_DelayTimer_timeout() -> void:
	fade_out()


func fade_out() -> void:
	$AnimationPlayer.play("fade_out")
