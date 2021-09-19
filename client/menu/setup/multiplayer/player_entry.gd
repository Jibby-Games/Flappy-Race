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
	$PlayerIcon.visible = not is_spectating
	$SpectateIcon.visible = is_spectating


func set_host(is_host: bool) -> void:
	$HostPlaceholder/HostIcon.visible = is_host
