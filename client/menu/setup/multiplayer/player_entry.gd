extends HBoxContainer

func _ready() -> void:
	$Control/Player.set_physics_process(false)


func setup(player_id: int, colour_choice: int) -> void:
	set_name(str(player_id))
	$Name.text = str(player_id)
	$Control/Player.set_body_colour(colour_choice)
