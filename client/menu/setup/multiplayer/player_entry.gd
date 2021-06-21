extends HBoxContainer

func _ready() -> void:
	$Control/Player.set_physics_process(false)


func setup(player_id: int, player_name: String, colour_choice: int) -> void:
	set_name(str(player_id))
	$Name.text = player_name
	set_colour(colour_choice)


func set_colour(colour_choice: int) -> void:
	$Control/Player.set_body_colour(colour_choice)
