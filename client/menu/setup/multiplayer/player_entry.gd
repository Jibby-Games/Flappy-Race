extends HBoxContainer

var player_id: int
var is_bot := false
var is_host := false


func _ready() -> void:
	$PlayerIcon/Player.set_physics_process(false)


func setup(_player_id: int, player_name: String, colour_choice: int, _is_bot: bool) -> void:
	player_id = _player_id
	is_bot = _is_bot
	set_name(str(player_id))
	$Name.text = player_name
	set_colour(colour_choice)


func set_colour(colour_choice: int) -> void:
	$PlayerIcon/Player.set_body_colour(colour_choice)


func set_spectating(is_spectating: bool) -> void:
	$PlayerIcon.visible = not is_spectating
	$SpectateIcon.visible = is_spectating


func set_host(value: bool) -> void:
	is_host = value
	$HostIcon.visible = is_host
	var show_host_buttons := not is_host and Network.Client.is_host() and not is_bot
	show_host_buttons(show_host_buttons)


func show_host_buttons(value: bool) -> void:
	$HostPlaceholder.visible = value
	$HostPlaceholder/Promote.visible = value
	$HostPlaceholder/Kick.visible = value


func _on_Promote_pressed() -> void:
	Network.Client.send_host_change_request(player_id)


func _on_Kick_button_down() -> void:
	Network.Client.send_kick_request(player_id)
