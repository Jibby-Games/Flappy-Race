extends HBoxContainer

func _ready() -> void:
	$Control/Player.set_physics_process(false)


func setup(player_id: int) -> void:
	set_name(str(player_id))
	$Name.text = str(player_id)
