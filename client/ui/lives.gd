extends MarginContainer


func set_lives(value: int) -> void:
	for i in $LifeBar.get_child_count():
		$LifeBar.get_child(i).visible = value > i
	if value > 10:
		$LifeBar/ExtraLives.text = "+ %d" % (value - 10)
