extends HBoxContainer


func _ready() -> void:
	$PlayerIcon/Player.set_physics_process(false)


func setup(player_id: int, player_name: String, colour_choice: int) -> void:
	set_name(str(player_id))
	$Name.text = player_name
	set_colour(colour_choice)


func set_colour(colour_choice: int) -> void:
	$PlayerIcon/Player.set_body_colour(colour_choice)


func set_spectating(is_spectating: bool) -> void:
	if is_spectating:
		$PlayerIcon.hide()
		$SpectateIcon.show()
	else:
		$PlayerIcon.show()
		$SpectateIcon.hide()


func set_host(is_host: bool) -> void:
	if is_host:
		$HostPlaceholder/HostIcon.show()
	else:
		$HostPlaceholder/HostIcon.hide()
